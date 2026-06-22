import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Confirmation dialog for dangerous or important actions.
class ConfirmDialog {
  ConfirmDialog._();

  /// Show a confirmation dialog.
  ///
  /// Returns `true` if confirmed, `false` if cancelled, `null` if dismissed.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Hủy',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelLabel,
              style: const TextStyle(color: AppColors.neutral700),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  isDangerous ? AppColors.danger : AppColors.green,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
