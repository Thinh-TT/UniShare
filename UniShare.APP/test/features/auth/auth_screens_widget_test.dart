import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unishare/config/app_config.dart';
import 'package:unishare/features/auth/presentation/providers/auth_provider.dart';
import 'package:unishare/features/auth/presentation/providers/auth_state.dart';
import 'package:unishare/features/auth/presentation/screens/login_screen.dart';
import 'package:unishare/features/auth/presentation/screens/register_screen.dart';
import 'package:unishare/features/notifications/presentation/providers/notifications_provider.dart'
    show unreadCountProvider;
import 'package:unishare/features/users/presentation/providers/user_provider.dart';
import 'package:unishare/features/users/models/user_profile_dto.dart';
import 'package:unishare/features/users/presentation/screens/profile_screen.dart';
import 'package:unishare/features/users/presentation/screens/edit_profile_screen.dart';
import 'package:unishare/shared/widgets/app_button.dart';
import 'package:unishare/shared/widgets/app_input.dart';

// ---------------------------------------------------------------------------
// A fake notifier that holds a fixed state for testing.
// ---------------------------------------------------------------------------
class _FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _FakeAuthNotifier(super.state);

  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> register({
    required String email,
    String? phoneNumber,
    required String password,
    required String fullName,
  }) async {}
  @override
  Future<void> tryAutoLogin() async {}
}

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Wrap a widget with auth state override.
Widget wrapWithAuthState(Widget child, AuthState state) {
  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(AppConfig.dev),
      authProvider.overrideWith((ref) => _FakeAuthNotifier(state)),
    ],
    child: MaterialApp(home: child),
  );
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

final _sampleUser = UserProfileDto(
  id: 'user-1',
  email: 'user@example.com',
  phoneNumber: '0912345678',
  fullName: 'Nguyen Van A',
  avatarUrl: null,
  schoolId: 'school-1',
  schoolName: 'Đại học Bách Khoa',
  areaId: 'area-1',
  areaName: 'Quận 10',
  reputationScore: 95.5,
  totalReviews: 12,
  isVerified: true,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  // =========================================================================
  // Login Screen Widget Tests
  // =========================================================================
  group('LoginScreen', () {
    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      // Logo and branding
      expect(find.text('UniShare'), findsOneWidget);
      expect(find.text('Chia sẻ đồ dùng sinh viên'), findsOneWidget);

      // "Đăng nhập" appears as title AND button — at least 2 widgets
      expect(find.text('Đăng nhập'), findsAtLeast(2));

      // Form field labels
      expect(find.text('Email / Số điện thoại'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);

      // Links
      expect(find.text('Tạo tài khoản mới'), findsOneWidget);
      expect(find.text('Xem đồ trước'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      // Tap login without filling form
      final loginButton = find.widgetWithText(AppButton, 'Đăng nhập');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập email hoặc số điện thoại'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    });

    testWidgets('shows email validation error for invalid email', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(AppInput, 'Email / Số điện thoại'),
        'notanemail@',
      );
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(AppButton, 'Đăng nhập');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('shows short phone validation error', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(AppInput, 'Email / Số điện thoại'),
        '123',
      );
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(AppButton, 'Đăng nhập');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Số điện thoại không hợp lệ'), findsOneWidget);
    });

    testWidgets('shows password too short error', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(AppInput, 'Email / Số điện thoại'),
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(AppInput, 'Mật khẩu'),
        '12345',
      );
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(AppButton, 'Đăng nhập');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('button shows loading state when AuthLoading', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthLoading()),
      );
      // Use pump() — CircularProgressIndicator animates forever
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('form is disabled during loading', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const LoginScreen(), AuthLoading()),
      );
      await tester.pump();

      // AbsorbPointer wraps the form during loading
      expect(find.byType(AbsorbPointer), findsAtLeast(1));
    });
  });

  // =========================================================================
  // Register Screen Widget Tests
  // =========================================================================
  group('RegisterScreen', () {
    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Tạo tài khoản'), findsOneWidget);

      // Form field labels
      expect(find.text('Họ tên'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);

      // Button and link
      expect(find.text('Đăng ký'), findsOneWidget);
      expect(find.text('Đã có tài khoản? Đăng nhập'), findsOneWidget);
    });

    testWidgets('shows validation errors for all required fields', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
      expect(find.text('Vui lòng nhập email'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
      expect(find.text('Vui lòng xác nhận mật khẩu'), findsOneWidget);
    });

    testWidgets('validates full name minimum length', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(AppInput, 'Họ tên'), 'A');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Họ tên phải có ít nhất 2 ký tự'), findsOneWidget);
    });

    testWidgets('validates email format', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(AppInput, 'Email'), 'invalid');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Email không hợp lệ'), findsOneWidget);
    });

    testWidgets('validates phone format', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(AppInput, 'Số điện thoại'), 'abc');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(
        find.text('Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)'),
        findsOneWidget,
      );
    });

    testWidgets('validates password minimum length', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(AppInput, 'Mật khẩu'), '12345');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('validates confirm password mismatch', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(AppInput, 'Mật khẩu'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(AppInput, 'Xác nhận mật khẩu'),
        'different',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });

    testWidgets('button shows loading when AuthLoading', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthLoading()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('phone field is optional and accepts empty', (tester) async {
      await tester.pumpWidget(
        wrapWithAuthState(const RegisterScreen(), AuthUnauthenticated()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(AppInput, 'Họ tên'), 'Nguyen Van A');
      await tester.enterText(find.widgetWithText(AppInput, 'Email'), 'user@example.com');
      await tester.enterText(find.widgetWithText(AppInput, 'Mật khẩu'), 'password123');
      await tester.enterText(find.widgetWithText(AppInput, 'Xác nhận mật khẩu'), 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(AppButton, 'Đăng ký'));
      await tester.pumpAndSettle();

      // Phone optional → no phone error
      expect(
        find.text('Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)'),
        findsNothing,
      );
    });
  });

  // =========================================================================
  // Profile Screen Widget Tests
  // =========================================================================
  group('ProfileScreen', () {
    /// Wrap with both auth state and resolved user profile provider.
    Widget wrapProfileWith(UserProfileDto profile) {
      return ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev),
          authProvider.overrideWith((ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: profile,
                ),
              )),
          userProfileProvider.overrideWith((ref) => Future.value(profile)),
          unreadCountProvider.overrideWith((ref) => Future.value(0)),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      );
    }

    testWidgets('renders profile content when loaded', (tester) async {
      await tester.pumpWidget(wrapProfileWith(_sampleUser));
      await tester.pumpAndSettle();

      // User info in the header card
      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('user@example.com'), findsOneWidget);
      expect(find.text('Đã xác thực'), findsOneWidget);

      // Stats card
      expect(find.text('95.5'), findsOneWidget);
      expect(find.text('Uy tín'), findsOneWidget);
      expect(find.text('Đánh giá'), findsOneWidget);

      // Menu items
      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
      expect(find.text('Bài đăng của tôi'), findsOneWidget);
      expect(find.text('Yêu cầu của tôi'), findsOneWidget);

      // Logout is at bottom — scroll to it
      await tester.scrollUntilVisible(
        find.text('Đăng xuất'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Đăng xuất'), findsOneWidget);
    });

    testWidgets('shows error state when profile fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleUser,
                  ),
                )),
            userProfileProvider.overrideWith(
              (ref) => Future.error(Exception('Network error')),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.textContaining('Không thể tải thông tin hồ sơ'), findsOneWidget);
    });
  });

  // =========================================================================
  // Edit Profile Screen Widget Tests
  // =========================================================================
  group('EditProfileScreen', () {
    /// Wrap with auth state and resolved user profile.
    Widget wrapEditWith(UserProfileDto profile) {
      return ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.dev),
          authProvider.overrideWith((ref) => _FakeAuthNotifier(
                AuthAuthenticated(
                  accessToken: 'token',
                  refreshToken: 'refresh',
                  user: profile,
                ),
              )),
          userProfileProvider.overrideWith((ref) => Future.value(profile)),
          unreadCountProvider.overrideWith((ref) => Future.value(0)),
        ],
        child: const MaterialApp(home: EditProfileScreen()),
      );
    }

    testWidgets('renders form fields pre-filled with profile data', (tester) async {
      await tester.pumpWidget(wrapEditWith(_sampleUser));
      await tester.pumpAndSettle();

      // App bar
      expect(find.text('Sửa hồ sơ'), findsOneWidget);

      // Form field labels
      expect(find.text('Họ tên'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Số điện thoại'), findsOneWidget);
      expect(find.text('Trường học'), findsOneWidget);
      expect(find.text('Khu vực'), findsOneWidget);

      // Avatar picker hint
      expect(find.text('Thay đổi ảnh đại diện'), findsOneWidget);

      // Save button
      expect(find.text('Lưu thay đổi'), findsOneWidget);
    });

    testWidgets('shows error state when profile fails to load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => _FakeAuthNotifier(
                  AuthAuthenticated(
                    accessToken: 'token',
                    refreshToken: 'refresh',
                    user: _sampleUser,
                  ),
                )),
            userProfileProvider.overrideWith(
              (ref) => Future.error(Exception('Failed to load')),
            ),
          ],
          child: const MaterialApp(home: EditProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Thử lại'), findsOneWidget);
      expect(find.textContaining('Không thể tải thông tin hồ sơ'), findsOneWidget);
    });

    testWidgets('validates full name is required', (tester) async {
      await tester.pumpWidget(wrapEditWith(_sampleUser));
      await tester.pumpAndSettle();

      // Clear the pre-filled name
      await tester.enterText(find.widgetWithText(AppInput, 'Họ tên'), '');
      await tester.pumpAndSettle();

      // Scroll save button into view, then tap
      await tester.scrollUntilVisible(
        find.text('Lưu thay đổi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(AppButton, 'Lưu thay đổi'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập họ tên'), findsOneWidget);
    });

    testWidgets('validates phone format when provided', (tester) async {
      await tester.pumpWidget(wrapEditWith(_sampleUser));
      await tester.pumpAndSettle();

      // Enter invalid phone
      await tester.enterText(find.widgetWithText(AppInput, 'Số điện thoại'), 'abc');
      await tester.pumpAndSettle();

      // Scroll to save button
      await tester.scrollUntilVisible(
        find.text('Lưu thay đổi'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(AppButton, 'Lưu thay đổi'));
      await tester.pumpAndSettle();

      expect(
        find.text('Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)'),
        findsOneWidget,
      );
    });
  });
}
