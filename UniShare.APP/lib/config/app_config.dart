import 'package:flutter/foundation.dart';
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

  /// Base URL for media files (uploads, avatars, etc.).
  ///
  /// Strips the `/api/v1` suffix from [apiBaseUrl] so it can be used to
  /// resolve server-relative image URLs (e.g. `/uploads/listings/...`).
  ///
  /// Examples:
  /// - `http://localhost:5056/api/v1` → `http://localhost:5056`
  /// - `https://staging-api.unishare.com/api/v1` → `https://staging-api.unishare.com`
  String get mediaBaseUrl => apiBaseUrl.replaceAll('/api/v1', '');

  /// Development: local backend.
  /// - Android emulator: uses 10.0.2.2 to reach host machine's localhost.
  /// - Web: uses localhost directly (10.0.2.2 does not resolve in browsers).
  static const AppConfig dev = AppConfig._(
    apiBaseUrl: 'http://10.0.2.2:5056/api/v1',
    signalrHubUrl: 'http://10.0.2.2:5056/hubs/chat',
    environment: 'dev',
  );

  /// Development (web): same backend as [dev] but uses localhost so the
  /// browser can reach the API. Flutter web cannot resolve 10.0.2.2.
  static const AppConfig devWeb = AppConfig._(
    apiBaseUrl: 'http://localhost:5056/api/v1',
    signalrHubUrl: 'http://localhost:5056/hubs/chat',
    environment: 'dev-web',
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

  /// ngrok tunnel: exposes a local Docker backend via a public HTTPS URL.
  /// Use for testing on a real physical device outside your LAN.
  ///
  /// Replace `<your-ngrok-domain>` with your actual ngrok URL
  /// (e.g., `abc123.ngrok-free.app`), or use the dynamic
  /// `--dart-define=NGROK_DOMAIN=<domain>` approach instead.
  static const AppConfig ngrok = AppConfig._(
    apiBaseUrl: 'https://<your-ngrok-domain>/api/v1',
    signalrHubUrl: 'https://<your-ngrok-domain>/hubs/chat',
    environment: 'ngrok',
  );

  /// Reads the [ENV] and [API_HOST] dart-defines and returns the matching config.
  ///
  /// If `--dart-define=NGROK_DOMAIN=<domain>` is provided, creates an ngrok config
  /// using that domain. If `--dart-define=API_HOST=<ip>` is provided, creates a
  /// dynamic LAN config. Otherwise falls back to [ENV] (dev/staging/lan/ngrok).
  ///
  /// On web, defaults to [AppConfig.devWeb] (localhost) instead of [AppConfig.dev]
  /// (10.0.2.2) because browsers cannot resolve the Android emulator address.
  factory AppConfig.fromDartDefine() {
    // --dart-define=NGROK_DOMAIN=<your-ngrok-domain>
    const ngrokDomain = String.fromEnvironment('NGROK_DOMAIN', defaultValue: '');
    if (ngrokDomain.isNotEmpty) {
      return AppConfig._(
        apiBaseUrl: 'https://$ngrokDomain/api/v1',
        signalrHubUrl: 'https://$ngrokDomain/hubs/chat',
        environment: 'ngrok',
      );
    }

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
      case 'ngrok':
        return ngrok;
      case 'dev':
        // When explicitly set to dev, respect platform
        return kIsWeb ? devWeb : dev;
      default:
        // Auto-detect: web uses localhost, otherwise use 10.0.2.2
        return kIsWeb ? devWeb : dev;
    }
  }
}

/// Riverpod provider for AppConfig.
///
/// Must be overridden in ProviderScope at app startup.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError('Override appConfigProvider in ProviderScope');
});