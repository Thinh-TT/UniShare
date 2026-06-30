import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import 'notification_signalr_client.dart';
import 'token_storage.dart';

export 'notification_signalr_client.dart';

/// Singleton provider for [NotificationSignalRService].
///
/// The service is lazily created on first read and automatically disposed
/// when the provider is discarded (app shutdown).
final notificationSignalRServiceProvider =
    Provider<NotificationSignalRService>((ref) {
  // Create a dedicated TokenStorage instance (lightweight wrapper around
  // FlutterSecureStorage + SharedPreferences) rather than sharing the
  // auth singleton, to avoid a circular import with auth_provider.dart.
  final service = NotificationSignalRService(
    appConfig: ref.read(appConfigProvider),
    tokenStorage: TokenStorage(),
  );
  ref.onDispose(() => service.dispose());
  return service;
});
