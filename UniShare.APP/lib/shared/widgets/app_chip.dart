import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Chip with default and selected states matching UniShare design.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;

  const AppChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onSelected,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      avatar: avatar,
      backgroundColor: AppColors.white,
      selectedColor: AppColors.greenLight,
      checkmarkColor: AppColors.green,
      side: BorderSide(
        color: isSelected ? AppColors.green : AppColors.neutral200,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.greenDark : AppColors.neutral700,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
