import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage using platform keychain/keystore.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorage()
      : _storage = const FlutterSecureStorage(
          // NOTE: encryptedSharedPreferences: true can hang on Samsung devices
          // due to Knox/TIMA KeyStore issues. Use default implementation instead.
          aOptions: AndroidOptions(
            encryptedSharedPreferences: false,
            sharedPreferencesName: 'unishare_prefs',
          ),
        );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]).timeout(const Duration(seconds: 5));
    } catch (_) {
      // Storage write failed or timed out (e.g. KeyStore unavailable).
      // Tokens won't be persisted but the caller can still proceed.
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage
          .read(key: _accessTokenKey)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Storage read failed or timed out (e.g. KeyStore unavailable,
      // web IndexedDB blocked, platform channel hung).
      // Treat as no token — caller should proceed to login.
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage
          .read(key: _refreshTokenKey)
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Storage read failed or timed out — treat as no token.
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Best-effort: if delete fails, tokens remain in storage.
    }
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
