import 'dart:async';
import 'package:signalr_netcore/ihub_protocol.dart' show MessageHeaders;
import 'package:signalr_netcore/signalr_client.dart';
import '../../config/app_config.dart';
import 'token_storage.dart';

/// SignalR real-time client for chat.
///
/// Connects to the ASP.NET Core SignalR hub at `/hubs/chat`.
/// Notification SignalR is handled by [NotificationSignalRService].
class SignalRService {
  final AppConfig _appConfig;
  final TokenStorage _tokenStorage;

  HubConnection? _hubConnection;
  bool _isConnected = false;

  final _messageReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  SignalRService({
    required AppConfig appConfig,
    required TokenStorage tokenStorage,
  })  : _appConfig = appConfig,
        _tokenStorage = tokenStorage;

  /// Stream of incoming messages.
  Stream<Map<String, dynamic>> get onMessageReceived =>
      _messageReceivedController.stream;

  /// Stream of connection state changes.
  Stream<bool> get onConnectionStateChanged =>
      _connectionStateController.stream;

  bool get isConnected => _isConnected;

  /// Connect to the SignalR hub.
  Future<void> connect() async {
    if (_isConnected) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null) return;

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          _appConfig.signalrHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
            transport: HttpTransportType.WebSockets,
            headers: MessageHeaders()
              ..setHeaderValue('ngrok-skip-browser-warning', 'true'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hubConnection!.on('MessageReceived', (args) {
      if (args != null && args.isNotEmpty) {
        _messageReceivedController.add(args[0] as Map<String, dynamic>);
      }
    });

    _hubConnection!.onclose(({error}) {
      _isConnected = false;
      _connectionStateController.add(false);
    });

    _hubConnection!.onreconnected(({connectionId}) {
      _isConnected = true;
      _connectionStateController.add(true);
    });

    await _hubConnection!.start();
    _isConnected = true;
    _connectionStateController.add(true);
  }

  /// Join a conversation group.
  Future<void> joinConversation(String conversationId) async {
    if (_hubConnection == null || !_isConnected) return;
    await _hubConnection!
        .invoke('JoinConversation', args: [conversationId]);
  }

  /// Leave a conversation group.
  Future<void> leaveConversation(String conversationId) async {
    if (_hubConnection == null || !_isConnected) return;
    await _hubConnection!
        .invoke('LeaveConversation', args: [conversationId]);
  }

  /// Send a message via SignalR.
  ///
  /// Backend ChatHub.SendMessage expects two primitive args:
  /// (Guid conversationId, string content).
  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (_hubConnection == null || !_isConnected) return;
    try {
      await _hubConnection!.invoke('SendMessage', args: [
        conversationId,
        content,
      ]);
    } catch (_) {
      // SignalR send failed — caller should fall back to HTTP
      rethrow;
    }
  }

  /// Mark a conversation's messages as read.
  ///
  /// Backend ChatHub.MarkAsRead expects one primitive arg:
  /// (Guid conversationId).
  Future<void> markAsRead({
    required String conversationId,
  }) async {
    if (_hubConnection == null || !_isConnected) return;
    try {
      await _hubConnection!
          .invoke('MarkAsRead', args: [conversationId]);
    } catch (_) {
      // Non-critical — messages will be marked read on next HTTP call
    }
  }

  /// Disconnect from the hub.
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _isConnected = false;
      _connectionStateController.add(false);
    }
  }

  /// Clean up resources.
  void dispose() {
    disconnect();
    _messageReceivedController.close();
    _connectionStateController.close();
  }
}
