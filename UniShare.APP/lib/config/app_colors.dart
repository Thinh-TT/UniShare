import 'package:flutter/material.dart';

/// Centralized color constants following UniShare color guidelines.
///
/// Reference: docs/04-ui/02-color-guidelines.md
class AppColors {
  AppColors._();

  // Primary
  static const Color white = Color(0xFFFFFFFF);

  // Green palette
  static const Color green = Color(0xFF16A34A);
  static const Color greenDark = Color(0xFF15803D);
  static const Color greenLight = Color(0xFFDCFCE7);

  // Neutral palette
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral900 = Color(0xFF111827);

  // Semantic / state colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  static const Color disabled = Color(0xFFD1D5DB);
}
