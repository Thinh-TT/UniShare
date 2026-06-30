import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage using platform keychain/keystore
/// with SharedPreferences fallback when secure storage is unavailable.
///
/// On some Android devices (e.g. Samsung Knox), FlutterSecureStorage can hang
/// or throw. This class mitigates by:
///   - Writing tokens to BOTH storages on save
///   - Falling back to SharedPreferences when secure storage read fails
///   - Migrating tokens back to secure storage on read when possible
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _spPrefix = 'sp_';

  final FlutterSecureStorage _secureStorage;
  SharedPreferences? _prefs;

  TokenStorage()
      : _secureStorage = const FlutterSecureStorage(
          // NOTE: encryptedSharedPreferences: true can hang on Samsung devices
          // due to Knox/TIMA KeyStore issues. Use default implementation instead.
          aOptions: AndroidOptions(
            encryptedSharedPreferences: false,
            sharedPreferencesName: 'unishare_prefs',
          ),
        );

  /// Lazily initialize SharedPreferences (called from all public methods).
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Write ────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Write to secure storage
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      ]).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[TokenStorage] Secure storage write failed: $e');
    }

    // Write to SharedPreferences fallback
    try {
      final prefs = await _getPrefs();
      await Future.wait([
        prefs.setString('$_spPrefix$_accessTokenKey', accessToken),
        prefs.setString('$_spPrefix$_refreshTokenKey', refreshToken),
      ]);
    } catch (e) {
      debugPrint('[TokenStorage] SharedPreferences write failed: $e');
    }
  }

  // ── Read ─────────────────────────────────────────────────────────────

  Future<String?> getAccessToken() async {
    // Try secure storage first
    try {
      final token = await _secureStorage
          .read(key: _accessTokenKey)
          .timeout(const Duration(seconds: 5));
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      debugPrint('[TokenStorage] Secure storage read failed (accessToken): $e');
    }

    // Fallback to SharedPreferences
    return _fallbackRead(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    // Try secure storage first
    try {
      final token = await _secureStorage
          .read(key: _refreshTokenKey)
          .timeout(const Duration(seconds: 5));
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      debugPrint(
          '[TokenStorage] Secure storage read failed (refreshToken): $e');
    }

    // Fallback to SharedPreferences
    return _fallbackRead(_refreshTokenKey);
  }

  /// Read from SharedPreferences fallback.
  /// If found, migrate back to secure storage for next time.
  Future<String?> _fallbackRead(String key) async {
    try {
      final prefs = await _getPrefs();
      final value = prefs.getString('$_spPrefix$key');
      if (value != null && value.isNotEmpty) {
        // Migrate back to secure storage
        try {
          await _secureStorage.write(key: key, value: value);
        } catch (_) {
          // Migration is best-effort — SharedPreferences has the value.
        }
        return value;
      }
    } catch (e) {
      debugPrint('[TokenStorage] SharedPreferences read failed ($key): $e');
    }
    return null;
  }

  // ── Delete ───────────────────────────────────────────────────────────

  Future<void> clearTokens() async {
    // Clear secure storage
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('[TokenStorage] Secure storage clear failed: $e');
    }

    // Clear SharedPreferences fallback
    try {
      final prefs = await _getPrefs();
      await Future.wait([
        prefs.remove('$_spPrefix$_accessTokenKey'),
        prefs.remove('$_spPrefix$_refreshTokenKey'),
      ]);
    } catch (e) {
      debugPrint('[TokenStorage] SharedPreferences clear failed: $e');
    }
  }

  // ── Utility ──────────────────────────────────────────────────────────

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
