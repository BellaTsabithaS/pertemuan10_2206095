// Purpose: Typography tokens mapped from DESIGN.md.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter TextStyle.
// Main/public functions: AppTextStyles.
// Side effects: None.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const fontFamily = 'Roboto';

  static const heroDisplay = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 1.07,
    letterSpacing: -0.28,
    color: AppColors.ink,
  );

  static const displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.10,
    color: AppColors.ink,
  );

  static const tagline = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.19,
    letterSpacing: 0.231,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.47,
    letterSpacing: -0.374,
    color: AppColors.body,
  );

  static const bodyStrong = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.24,
    letterSpacing: -0.374,
    color: AppColors.body,
  );

  static const caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: -0.224,
    color: AppColors.inkMuted80,
  );

  static const captionStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: -0.224,
    color: AppColors.ink,
  );

  static const finePrint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: -0.12,
    color: AppColors.inkMuted48,
  );
}
