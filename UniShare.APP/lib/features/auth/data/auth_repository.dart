import '../../../core/network/token_storage.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/refresh_token_request.dart';
import '../../users/models/user_profile_dto.dart';
import 'auth_api.dart';

/// Orchestrates authentication logic: API calls + token persistence.
class AuthRepository {
  final AuthApi _authApi;
  final TokenStorage _tokenStorage;

  AuthRepository({
    required AuthApi authApi,
    required TokenStorage tokenStorage,
  })  : _authApi = authApi,
        _tokenStorage = tokenStorage;

  /// Login with credentials, persist tokens, return user.
  Future<UserProfileDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.login(
      LoginRequest(login: email, password: password),
    );
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return response.user;
  }

  /// Register a new account.
  Future<void> register({
    required String email,
    String? phoneNumber,
    required String password,
    required String fullName,
  }) async {
    await _authApi.register(
      RegisterRequest(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        fullName: fullName,
      ),
    );
  }

  /// Try to restore session from stored tokens.
  /// Returns [UserProfileDto] if successful, null if no valid session.
  ///
  /// Has a hard 4-second timeout so the splash screen never hangs.
  Future<UserProfileDto?> tryAutoLogin() async {
    try {
      return await _doTryAutoLogin().timeout(const Duration(seconds: 4));
    } catch (_) {
      // Timeout or any other error — clear stale tokens and proceed to login.
      await _clearTokensSafely();
      return null;
    }
  }

  Future<UserProfileDto?> _doTryAutoLogin() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final response = await _authApi.refreshToken(
        RefreshTokenRequest(refreshToken: refreshToken),
      );
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return response.user;
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  Future<void> _clearTokensSafely() async {
    try {
      await _tokenStorage.clearTokens();
    } catch (_) {
      // Best-effort
    }
  }

  /// Get current user profile from API.
  Future<UserProfileDto> getProfile() async {
    return _authApi.getMyProfile();
  }

  /// Logout and clear tokens.
  Future<void> logout() async {
    await _authApi.logout();
    await _tokenStorage.clearTokens();
  }
}
