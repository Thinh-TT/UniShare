import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Pre-configured button variants matching UniShare color guidelines.
enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isDisabled;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isDisabled = false,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  bool get _disabled => isDisabled || isLoading;

  @override
  Widget build(BuildContext context) {
    final child = _buildChild();

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: _disabled ? null : onPressed,
            style: _disabled
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.disabled,
                    foregroundColor: AppColors.neutral500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  )
                : null,
            child: child,
          ),
        );

      case AppButtonVariant.secondary:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: OutlinedButton(
            onPressed: _disabled ? null : onPressed,
            child: child,
          ),
        );

      case AppButtonVariant.ghost:
        return SizedBox(
          height: height,
          child: TextButton(
            onPressed: _disabled ? null : onPressed,
            child: child,
          ),
        );

      case AppButtonVariant.danger:
        return SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: _disabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.disabled,
              disabledForegroundColor: AppColors.neutral500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: child,
          ),
        );
    }
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
