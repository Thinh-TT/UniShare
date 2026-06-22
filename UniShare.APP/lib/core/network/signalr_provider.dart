import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../features/auth/presentation/providers/auth_provider.dart'
    show tokenStorageProvider;
import 'signalr_client.dart';

/// Singleton provider for the SignalR real-time service.
///
/// Connect on first use (lazy). Disconnect on app close or logout.
final signalRServiceProvider = Provider<SignalRService>((ref) {
  final service = SignalRService(
    appConfig: ref.read(appConfigProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});
