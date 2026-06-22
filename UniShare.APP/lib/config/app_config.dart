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

  /// LAN: for testing on a real physical device connected to the same
  /// Wi-Fi/LAN as the machine running the backend (`dotnet run`).
  /// 10.0.2.2 only works on the Android emulator, so real devices need
  /// the host machine's actual LAN IP address instead.
  static const AppConfig lan = AppConfig._(
    apiBaseUrl: 'http://192.168.2.2:5056/api/v1',
    signalrHubUrl: 'http://192.168.2.2:5056/hubs/chat',
    environment: 'lan',
  );

  /// Reads the [ENV] and [API_HOST] dart-defines and returns the matching config.
  ///
  /// If `--dart-define=API_HOST=<ip>` is provided, creates a dynamic LAN config
  /// using that IP. Otherwise falls back to [ENV] (dev/staging/lan).
  /// Defaults to [AppConfig.dev] if neither is specified.
  factory AppConfig.fromDartDefine() {
    const apiHost = String.fromEnvironment('API_HOST', defaultValue: '');
    if (apiHost.isNotEmpty) {
      return AppConfig._(
        apiBaseUrl: 'http://$apiHost:5056/api/v1',
        signalrHubUrl: 'http://$apiHost:5056/hubs/chat',
        environment: 'lan',
      );
    }

    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    switch (env) {
      case 'staging':
        return staging;
      case 'lan':
        return lan;
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