import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_colors.dart';
import 'app_button.dart';
import 'app_bottom_sheet.dart';

/// Modal bottom sheet displayed when a guest user tries a protected action.
class LoginRequiredModal {
  LoginRequiredModal._();

  static Future<void> show(BuildContext context) async {
    await AppBottomSheet.show(
      context: context,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn cần đăng nhập',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập để sử dụng tính năng này và kết nối với cộng đồng chia sẻ đồ dùng sinh viên.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Đăng nhập',
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/login');
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/register');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Tạo tài khoản mới'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Xem tiếp với tư cách khách',
                style: TextStyle(color: AppColors.neutral500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
