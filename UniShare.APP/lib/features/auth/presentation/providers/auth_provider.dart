import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_config.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../data/auth_api.dart';
import '../../data/auth_repository.dart';
import 'auth_state.dart';

// -- Dependency providers --

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    appConfig: ref.read(appConfigProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(apiClient: ref.read(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    authApi: ref.read(authApiProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

// -- Auth state notifier --

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(tokenStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;

  AuthNotifier(this._authRepository, this._tokenStorage) : super(AuthInitial());

  /// Check for existing session on app start.
  Future<void> tryAutoLogin() async {
    state = AuthLoading();
    final user = await _authRepository.tryAutoLogin();
    if (user != null) {
      final accessToken =
          await _tokenStorage.getAccessToken() ?? '';
      final refreshToken =
          await _tokenStorage.getRefreshToken() ?? '';
      state = AuthAuthenticated(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } else {
      state = AuthUnauthenticated();
    }
  }

  /// Login with email and password.
  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      final accessToken =
          await _tokenStorage.getAccessToken() ?? '';
      final refreshToken =
          await _tokenStorage.getRefreshToken() ?? '';
      state = AuthAuthenticated(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (e) {
      state = AuthUnauthenticated();
      rethrow;
    }
  }

  /// Register a new account.
  Future<void> register({
    required String email,
    String? phoneNumber,
    required String password,
    required String fullName,
  }) async {
    state = AuthLoading();
    try {
      await _authRepository.register(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        fullName: fullName,
      );
      // After registration, go back to unauthenticated (user needs to login)
      state = AuthUnauthenticated();
    } catch (e) {
      state = AuthUnauthenticated();
      rethrow;
    }
  }

  /// Logout.
  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthUnauthenticated();
  }
}
