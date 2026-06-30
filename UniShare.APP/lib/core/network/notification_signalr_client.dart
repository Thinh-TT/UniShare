import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/ihub_protocol.dart' show MessageHeaders;
import 'package:signalr_netcore/signalr_client.dart';
import '../../config/app_config.dart';
import '../../features/notifications/models/notification_dto.dart';
import 'token_storage.dart';

/// SignalR real-time client for notifications.
///
/// Connects to the ASP.NET Core SignalR hub at `/hubs/notifications`.
/// The backend automatically groups users by their userId on connect,
/// so no explicit join/leave methods are needed.
///
/// After receiving [NotificationDto], consumers should:
/// - Invalidate `unreadCountProvider`
/// - Optionally show a SnackBar with navigation action
class NotificationSignalRService {
  final AppConfig _appConfig;
  final TokenStorage _tokenStorage;

  HubConnection? _hubConnection;
  bool _isConnected = false;

  final _notificationReceivedController =
      StreamController<NotificationDto>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  NotificationSignalRService({
    required AppConfig appConfig,
    required TokenStorage tokenStorage,
  })  : _appConfig = appConfig,
        _tokenStorage = tokenStorage;

  /// Stream of incoming notifications as parsed [NotificationDto].
  Stream<NotificationDto> get onNotificationReceived =>
      _notificationReceivedController.stream;

  /// Stream of connection state changes.
  Stream<bool> get onConnectionStateChanged =>
      _connectionStateController.stream;

  /// Whether the underlying WebSocket is currently connected.
  bool get isConnected => _isConnected;

  /// Derive the notification hub URL from the configured SignalR base URL.
  ///
  /// e.g. `http://10.0.2.2:5056/hubs/chat` → `http://10.0.2.2:5056/hubs/notifications`
  String get _hubUrl {
    final uri = Uri.parse(_appConfig.signalrHubUrl);
    return uri.replace(path: '/hubs/notifications').toString();
  }

  /// Connect to the notification hub.
  ///
  /// Safe to call multiple times — subsequent calls are no-ops if already
  /// connected. Requires a valid access token from [TokenStorage].
  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null) {
      debugPrint('[NotificationSignalRService] No token — skipping connect');
      return;
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
            headers: MessageHeaders()
              ..setHeaderValue('ngrok-skip-browser-warning', 'true'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('NotificationReceived', (args) {
      if (args != null && args.isNotEmpty) {
        try {
          final data = args[0] as Map<String, dynamic>;
          final notification = NotificationDto.fromJson(data);
          _notificationReceivedController.add(notification);
        } catch (e) {
          debugPrint('[NotificationSignalRService] Parse error: $e');
        }
      }
    });

    _hubConnection!.onclose(({error}) {
      debugPrint('[NotificationSignalRService] Closed: $error');
      _isConnected = false;
      _connectionStateController.add(false);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      debugPrint('[NotificationSignalRService] Reconnected: $connectionId');
      _isConnected = true;
      _connectionStateController.add(true);
    });

    try {
      await _hubConnection!.start();
      _isConnected = true;
      _connectionStateController.add(true);
      debugPrint('[NotificationSignalRService] Connected');
    } catch (e) {
      debugPrint('[NotificationSignalRService] Connection failed: $e');
      _isConnected = false;
    }
  }

  /// Disconnect from the hub.
  ///
  /// No-op if not connected.
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _isConnected = false;
      _connectionStateController.add(false);
      debugPrint('[NotificationSignalRService] Disconnected');
    }
  }

  /// Clean up resources.
  ///
  /// Disconnects and closes all stream controllers. Call once when the
  /// service is no longer needed (app dispose).
  void dispose() {
    disconnect();
    _notificationReceivedController.close();
    _connectionStateController.close();
  }
}
