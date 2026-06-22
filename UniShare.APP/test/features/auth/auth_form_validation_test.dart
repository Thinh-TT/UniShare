import 'package:flutter_test/flutter_test.dart';

/// Unit tests for auth form validation logic.
///
/// These tests verify the validation rules extracted from
/// [LoginScreen] and [RegisterScreen] without requiring widget pumping.
void main() {
  // =========================================================================
  // Validation rule helpers (mirrors screen logic)
  // =========================================================================

  /// Login screen: validate login field (email or phone).
  String? validateLogin(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Vui lòng nhập email hoặc số điện thoại';
    }
    if (trimmed.contains('@')) {
      final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
      if (!emailRegex.hasMatch(trimmed)) {
        return 'Email không hợp lệ';
      }
    } else if (trimmed.length < 6) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  /// Login/Register screens: validate password field.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  /// Register screen: validate full name field.
  String? validateFullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (trimmed.length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  /// Register screen: validate email field.
  String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Register/Edit Profile screens: validate phone field (optional).
  String? validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null; // optional
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)';
    }
    return null;
  }

  /// Register screen: validate confirm password field.
  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // =========================================================================
  // Login field validation
  // =========================================================================
  group('Login field validation', () {
    group('validateLogin (email or phone)', () {
      test('returns error for empty value', () {
        expect(validateLogin(''), 'Vui lòng nhập email hoặc số điện thoại');
        expect(validateLogin(null), 'Vui lòng nhập email hoặc số điện thoại');
        expect(validateLogin('   '), 'Vui lòng nhập email hoặc số điện thoại');
      });

      test('accepts valid email', () {
        expect(validateLogin('user@example.com'), isNull);
        expect(validateLogin('test.user@domain.vn'), isNull);
        expect(validateLogin('a@b.co'), isNull);
      });

      test('rejects invalid email format', () {
        expect(validateLogin('user@'), 'Email không hợp lệ');
        expect(validateLogin('@domain.com'), 'Email không hợp lệ');
        expect(validateLogin('user@domain'), 'Email không hợp lệ');
        expect(validateLogin('user domain@domain.com'), 'Email không hợp lệ');
        expect(validateLogin(''), isNot(isNull)); // empty
      });

      test('accepts phone-like strings (6+ chars, no @)', () {
        expect(validateLogin('0912345678'), isNull); // 10-digit phone
        expect(validateLogin('123456'), isNull); // min 6 chars
        expect(validateLogin('abcdef'), isNull); // 6 chars, non-email
        expect(validateLogin('admin123'), isNull);
      });

      test('rejects short non-email strings (< 6 chars)', () {
        expect(validateLogin('12345'), 'Số điện thoại không hợp lệ');
        expect(validateLogin('abc'), 'Số điện thoại không hợp lệ');
        expect(validateLogin('a'), 'Số điện thoại không hợp lệ');
      });

      test('handles leading/trailing whitespace', () {
        expect(validateLogin('  user@example.com  '), isNull);
        expect(validateLogin('  0912345678  '), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error for empty password', () {
        expect(validatePassword(''), 'Vui lòng nhập mật khẩu');
        expect(validatePassword(null), 'Vui lòng nhập mật khẩu');
      });

      test('returns error for short password', () {
        expect(validatePassword('12345'), 'Mật khẩu phải có ít nhất 6 ký tự');
        expect(validatePassword('abc'), 'Mật khẩu phải có ít nhất 6 ký tự');
        expect(validatePassword('a'), 'Mật khẩu phải có ít nhất 6 ký tự');
      });

      test('accepts password with 6+ characters', () {
        expect(validatePassword('123456'), isNull);
        expect(validatePassword('password'), isNull);
        expect(validatePassword('abcdefgh'), isNull);
        expect(validatePassword('P@ssw0rd!'), isNull);
      });
    });
  });

  // =========================================================================
  // Register field validation
  // =========================================================================
  group('Register field validation', () {
    group('validateFullName', () {
      test('returns error for empty name', () {
        expect(validateFullName(''), 'Vui lòng nhập họ tên');
        expect(validateFullName(null), 'Vui lòng nhập họ tên');
        expect(validateFullName('   '), 'Vui lòng nhập họ tên');
      });

      test('returns error for single character', () {
        expect(validateFullName('A'), 'Họ tên phải có ít nhất 2 ký tự');
        expect(validateFullName('X'), 'Họ tên phải có ít nhất 2 ký tự');
      });

      test('accepts names with 2+ characters', () {
        expect(validateFullName('An'), isNull);
        expect(validateFullName('Nguyen Van A'), isNull);
        expect(validateFullName('Trần Thị B'), isNull);
        expect(validateFullName('Lê Hoàng'), isNull);
      });
    });

    group('validateEmail (register)', () {
      test('returns error for empty email', () {
        expect(validateEmail(''), 'Vui lòng nhập email');
        expect(validateEmail(null), 'Vui lòng nhập email');
      });

      test('accepts valid emails', () {
        expect(validateEmail('user@example.com'), isNull);
        expect(validateEmail('test.user+tag@domain.co.uk'), isNull);
        expect(validateEmail('hello@school.edu.vn'), isNull);
      });

      test('rejects invalid emails', () {
        expect(validateEmail('plaintext'), 'Email không hợp lệ');
        expect(validateEmail('user@'), 'Email không hợp lệ');
        expect(validateEmail('@domain'), 'Email không hợp lệ');
        expect(validateEmail('a @b.com'), 'Email không hợp lệ');
        expect(validateEmail('user@domain'), 'Email không hợp lệ');
      });
    });

    group('validatePhone (optional)', () {
      test('returns null for empty phone (optional)', () {
        expect(validatePhone(''), isNull);
        expect(validatePhone(null), isNull);
        expect(validatePhone('   '), isNull);
      });

      test('accepts valid Vietnamese phone numbers', () {
        expect(validatePhone('0912345678'), isNull);
        expect(validatePhone('0987654321'), isNull);
        expect(validatePhone('0123456789'), isNull);
      });

      test('rejects invalid phone numbers', () {
        expect(
          validatePhone('12345'),
          'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)',
        );
        expect(
          validatePhone('091234567'),
          'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)',
        );
        expect(
          validatePhone('1912345678'),
          'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)',
        );
        expect(
          validatePhone('09123456789'),
          'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)',
        );
        expect(
          validatePhone('phonecall'),
          'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10 chữ số)',
        );
      });
    });

    group('validateConfirmPassword', () {
      test('returns error for empty confirmation', () {
        expect(validateConfirmPassword('', 'pass'), 'Vui lòng xác nhận mật khẩu');
        expect(validateConfirmPassword(null, 'pass'), 'Vui lòng xác nhận mật khẩu');
      });

      test('returns error for mismatch', () {
        expect(
          validateConfirmPassword('pass1', 'pass2'),
          'Mật khẩu xác nhận không khớp',
        );
        expect(
          validateConfirmPassword('abc', 'ABC'),
          'Mật khẩu xác nhận không khớp',
        );
        expect(
          validateConfirmPassword('password', 'PassWord'),
          'Mật khẩu xác nhận không khớp',
        );
      });

      test('accepts matching passwords', () {
        expect(validateConfirmPassword('password', 'password'), isNull);
        expect(validateConfirmPassword('abc123', 'abc123'), isNull);
        expect(validateConfirmPassword('P@ss!', 'P@ss!'), isNull);
      });
    });
  });

  // =========================================================================
  // Complete form validation scenarios
  // =========================================================================
  group('Complete form scenarios', () {
    test('login form: valid email + password passes', () {
      expect(validateLogin('user@example.com'), isNull);
      expect(validatePassword('password123'), isNull);
    });

    test('login form: valid phone + password passes', () {
      expect(validateLogin('0912345678'), isNull);
      expect(validatePassword('abcdef'), isNull);
    });

    test('login form: empty fields both fail', () {
      expect(validateLogin(''), isNotNull);
      expect(validatePassword(''), isNotNull);
    });

    test('register form: all valid fields pass', () {
      expect(validateFullName('Nguyen Van A'), isNull);
      expect(validateEmail('user@example.com'), isNull);
      expect(validatePhone(''), isNull); // optional
      expect(validatePassword('password123'), isNull);
      expect(validateConfirmPassword('password123', 'password123'), isNull);
    });

    test('register form: valid with phone passes', () {
      expect(validateFullName('Tran B'), isNull);
      expect(validateEmail('tranb@test.com'), isNull);
      expect(validatePhone('0912345678'), isNull);
      expect(validatePassword('secret123'), isNull);
      expect(validateConfirmPassword('secret123', 'secret123'), isNull);
    });

    test('register form: all fields fail with empty/invalid input', () {
      expect(validateFullName(''), isNotNull);
      expect(validateEmail(''), isNotNull);
      expect(validatePassword(''), isNotNull);
      expect(validateConfirmPassword('', 'any'), isNotNull);
    });

    test('register form: password mismatch fails', () {
      // All individual fields valid but confirm doesn't match
      expect(validateFullName('User'), isNull);
      expect(validateEmail('user@test.com'), isNull);
      expect(validatePassword('pass123'), isNull);
      expect(validateConfirmPassword('different', 'pass123'), isNotNull);
    });
  });
}
