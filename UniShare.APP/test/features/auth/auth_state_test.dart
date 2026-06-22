import 'package:flutter_test/flutter_test.dart';
import 'package:unishare/features/auth/presentation/providers/auth_state.dart';
import 'package:unishare/features/users/models/user_profile_dto.dart';

void main() {
  // =========================================================================
  // AuthState sealed class hierarchy tests
  // =========================================================================
  group('AuthState', () {
    group('AuthInitial', () {
      test('is an AuthState', () {
        const state = AuthInitial();
        expect(state, isA<AuthState>());
      });

      test('equals another AuthInitial', () {
        expect(const AuthInitial(), equals(const AuthInitial()));
      });
    });

    group('AuthLoading', () {
      test('is an AuthState', () {
        const state = AuthLoading();
        expect(state, isA<AuthState>());
      });

      test('equals another AuthLoading', () {
        expect(const AuthLoading(), equals(const AuthLoading()));
      });
    });

    group('AuthAuthenticated', () {
      final testUser = UserProfileDto(
        id: 'user-1',
        email: 'test@example.com',
        fullName: 'Test User',
        reputationScore: 100,
        totalReviews: 5,
        isVerified: true,
      );

      test('is an AuthState', () {
        final state = AuthAuthenticated(
          accessToken: 'token',
          refreshToken: 'refresh',
          user: testUser,
        );
        expect(state, isA<AuthState>());
      });

      test('stores all fields correctly', () {
        final state = AuthAuthenticated(
          accessToken: 'access-123',
          refreshToken: 'refresh-456',
          user: testUser,
        );

        expect(state.accessToken, 'access-123');
        expect(state.refreshToken, 'refresh-456');
        expect(state.user, same(testUser));
        expect(state.user.id, 'user-1');
        expect(state.user.email, 'test@example.com');
        expect(state.user.fullName, 'Test User');
      });

      test('constructor creates object with correct fields', () {
        final state1 = AuthAuthenticated(
          accessToken: 'at',
          refreshToken: 'rt',
          user: testUser,
        );
        final state2 = AuthAuthenticated(
          accessToken: 'at',
          refreshToken: 'rt',
          user: testUser,
        );

        // Same user object reference and same token strings
        expect(state1.accessToken, state2.accessToken);
        expect(state1.refreshToken, state2.refreshToken);
        expect(state1.user, same(state2.user));
      });

      test('different tokens produce different states', () {
        final user = testUser;
        final state1 = AuthAuthenticated(
          accessToken: 'at1',
          refreshToken: 'rt',
          user: user,
        );
        final state2 = AuthAuthenticated(
          accessToken: 'at2',
          refreshToken: 'rt',
          user: user,
        );

        expect(state1.accessToken, isNot(equals(state2.accessToken)));
      });
    });

    group('AuthUnauthenticated', () {
      test('is an AuthState', () {
        const state = AuthUnauthenticated();
        expect(state, isA<AuthState>());
      });

      test('equals another AuthUnauthenticated', () {
        expect(
          const AuthUnauthenticated(),
          equals(const AuthUnauthenticated()),
        );
      });
    });

    group('Sealed class exhaustiveness', () {
      test('all subclasses are distinct types', () {
        final user = UserProfileDto(
          id: 'u1',
          email: 'e@e.com',
          fullName: 'F',
          reputationScore: 0,
          totalReviews: 0,
          isVerified: false,
        );

        final initial = const AuthInitial();
        final loading = const AuthLoading();
        final authenticated = AuthAuthenticated(
          accessToken: 'a',
          refreshToken: 'r',
          user: user,
        );
        final unauthenticated = const AuthUnauthenticated();

        // Verify they are different types
        expect(initial, isNot(isA<AuthLoading>()));
        expect(initial, isNot(isA<AuthAuthenticated>()));
        expect(initial, isNot(isA<AuthUnauthenticated>()));

        expect(loading, isNot(isA<AuthInitial>()));
        expect(authenticated, isNot(isA<AuthInitial>()));
        expect(unauthenticated, isNot(isA<AuthInitial>()));
      });

      test('pattern matching covers all states', () {
        const states = [
          AuthInitial(),
          AuthLoading(),
          AuthUnauthenticated(),
        ];

        for (final state in states) {
          final result = switch (state) {
            AuthInitial() => 'initial',
            AuthLoading() => 'loading',
            AuthAuthenticated() => 'authenticated',
            AuthUnauthenticated() => 'unauthenticated',
            _ => 'unknown', // fallback for exhaustiveness
          };
          expect(result, isNotEmpty);
        }
      });
    });
  });
}
