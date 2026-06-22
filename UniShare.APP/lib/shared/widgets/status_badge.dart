import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Color-coded badge for listing/request/deposit statuses.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeColor color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  factory StatusBadge.fromStatus(String status) {
    return StatusBadge(
      label: status,
      color: _mapStatusToColor(status),
    );
  }

  static StatusBadgeColor _mapStatusToColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'paid':
      case 'completed':
      case 'active':
        return StatusBadgeColor.success;
      case 'pending':
        return StatusBadgeColor.warning;
      case 'reserved':
      case 'inprogress':
      case 'inuse':
        return StatusBadgeColor.info;
      case 'rejected':
      case 'cancelled':
      case 'closed':
        return StatusBadgeColor.danger;
      case 'refunded':
        return StatusBadgeColor.neutral;
      default:
        return StatusBadgeColor.neutral;
    }
  }

  Color get _backgroundColor {
    switch (color) {
      case StatusBadgeColor.success:
        return AppColors.greenLight;
      case StatusBadgeColor.warning:
        return const Color(0xFFFEF3C7);
      case StatusBadgeColor.danger:
        return const Color(0xFFFEE2E2);
      case StatusBadgeColor.info:
        return const Color(0xFFDBEAFE);
      case StatusBadgeColor.neutral:
        return AppColors.neutral100;
    }
  }

  Color get _textColor {
    switch (color) {
      case StatusBadgeColor.success:
        return AppColors.greenDark;
      case StatusBadgeColor.warning:
        return AppColors.warning;
      case StatusBadgeColor.danger:
        return AppColors.danger;
      case StatusBadgeColor.info:
        return AppColors.info;
      case StatusBadgeColor.neutral:
        return AppColors.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum StatusBadgeColor { success, warning, danger, info, neutral }
