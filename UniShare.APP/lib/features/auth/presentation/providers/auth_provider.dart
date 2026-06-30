import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_config.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/notification_signalr_provider.dart';
import '../../data/auth_api.dart';
import '../../data/auth_repository.dart';
import 'auth_state.dart';
export 'auth_state.dart';

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
    ref.read(notificationSignalRServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final NotificationSignalRService _notificationSignalR;

  AuthNotifier(
    this._authRepository,
    this._tokenStorage,
    this._notificationSignalR,
  ) : super(AuthInitial());

  /// Check for existing session on app start.
  ///
  /// ALWAYS transitions state out of [AuthLoading], even on error.
  /// This ensures the splash screen never hangs indefinitely.
  Future<void> tryAutoLogin() async {
    debugPrint('[AuthNotifier] tryAutoLogin: starting...');
    state = AuthLoading();
    try {
      final user = await _authRepository.tryAutoLogin();
      if (user != null) {
        final accessToken =
            await _tokenStorage.getAccessToken() ?? '';
        final refreshToken =
            await _tokenStorage.getRefreshToken() ?? '';

        // Validate: empty token means session is invalid despite user response
        if (accessToken.isEmpty || refreshToken.isEmpty) {
          debugPrint(
            '[AuthNotifier] tryAutoLogin: token empty despite user — '
            'forcing unauthenticated',
          );
          await _authRepository.logout();
          state = AuthUnauthenticated();
          return;
        }

        state = AuthAuthenticated(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );
        debugPrint('[AuthNotifier] tryAutoLogin: success — user=${user.id}');
        // Connect notification SignalR for real-time updates
        unawaited(_notificationSignalR.connect());
      } else {
        debugPrint('[AuthNotifier] tryAutoLogin: no session found');
        state = AuthUnauthenticated();
      }
    } catch (e, st) {
      // Storage error, network error, etc. — force unauthenticated.
      debugPrint('[AuthNotifier] tryAutoLogin: error=$e\n$st');
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
      // Connect notification SignalR for real-time updates
      unawaited(_notificationSignalR.connect());
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
    await _notificationSignalR.disconnect();
    await _authRepository.logout();
    state = AuthUnauthenticated();
  }
}
