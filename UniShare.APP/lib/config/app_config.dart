import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final String apiBaseUrl;
  final String signalrHubUrl;
  final String environment;

  const AppConfig._({
    required this.apiBaseUrl,
    required this.signalrHubUrl,
    required this.environment,
  });

  /// Development: local backend (Android emulator uses 10.0.2.2 for host)
  static const AppConfig dev = AppConfig._(
    apiBaseUrl: 'http://10.0.2.2:5056/api/v1',
    signalrHubUrl: 'http://10.0.2.2:5056/hubs/chat',
    environment: 'dev',
  );

  /// Staging: replace with your staging server URL
  static const AppConfig staging = AppConfig._(
    apiBaseUrl: 'https://staging-api.unishare.com/api/v1',
    signalrHubUrl: 'https://staging-api.unishare.com/hubs/chat',
    environment: 'staging',
  );

  /// Reads the [ENV] dart-define and returns the matching config.
  /// Defaults to [AppConfig.dev] if not specified.
  factory AppConfig.fromDartDefine() {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env) {
      case 'staging':
        return staging;
      default:
        return dev;
    }
  }
}

/// Riverpod provider for AppConfig.
///
/// Must be overridden in ProviderScope at app startup.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('Override appConfigProvider in ProviderScope');
});
