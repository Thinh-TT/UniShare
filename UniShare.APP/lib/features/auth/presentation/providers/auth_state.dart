import '../../users/models/user_profile_dto.dart';

/// Represents the current authentication state.
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final String refreshToken;
  final UserProfileDto user;

  const AuthAuthenticated({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class AuthUnauthenticated extends AuthState {}
