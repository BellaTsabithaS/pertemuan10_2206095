// Purpose: Color tokens mapped from DESIGN.md for the e-commerce app.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter Color.
// Main/public functions: AppColors.
// Side effects: None.

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Light Mode Tokens (Tailwind Inspired)
  static const backgroundLight = Color(0xFFFFFFFF);
  static const foregroundLight = Color(0xFF333333);
  static const mutedLight = Color(0xFFF9FAFB);
  static const mutedForegroundLight = Color(0xFF6B7280);
  static const secondaryForegroundLight = Color(0xFF4B5563);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryForegroundLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE5E7EB);
  static const destructiveLight = Color(0xFFEF4444);

  // Dark Mode Tokens (Tailwind Inspired)
  static const backgroundDark = Color(0xFF171717);
  static const foregroundDark = Color(0xFFE5E5E5);
  static const mutedDark = Color(0xFF1F1F1F);
  static const mutedForegroundDark = Color(0xFFA3A3A3);
  static const secondaryForegroundDark = Color(0xFFE5E5E5);
  static const primaryDark = Color(0xFF3B82F6);
  static const primaryForegroundDark = Color(0xFFFFFFFF);
  static const borderDark = Color(0xFF404040);
  static const destructiveDark = Color(0xFFEF4444);
  
  // Status Colors (Kept for compatibility)
  static const statusPending = Color(0xFFF59E0B);
  static const statusProcessing = Color(0xFF3B82F6);
  static const statusShipped = Color(0xFF8B5CF6);
  static const statusDelivered = Color(0xFF10B981);
  static const statusCancelled = destructiveLight;

  // Legacy mappings to prevent compilation errors
  static const primary = primaryLight;
  static const primaryFocus = Color(0xFF0071E3);
  static const primaryOnDark = primaryDark;
  static const ink = foregroundLight;
  static const body = foregroundLight;
  static const bodyOnDark = foregroundDark;
  static const bodyMuted = mutedForegroundLight;
  static const inkMuted80 = secondaryForegroundLight;
  static const inkMuted48 = mutedForegroundLight;
  static const dividerSoft = borderLight;
  static const hairline = borderLight;
  static const canvas = backgroundLight;
  static const canvasParchment = mutedLight;
  static const surfacePearl = mutedLight;
  static const surfaceTile1 = mutedDark;
  static const surfaceTile2 = backgroundDark;
  static const surfaceTile3 = mutedDark;
  static const surfaceBlack = Color(0xFF000000);
  static const surfaceChipTranslucent = Color(0xA3D2D2D7);
  static const onPrimary = primaryForegroundLight;
  static const onDark = primaryForegroundLight;
}

extension AppThemeContext on BuildContext {
  AppColorData get color => AppColorData(Theme.of(this).brightness == Brightness.dark);
}

class AppColorData {
  final bool isDark;
  const AppColorData(this.isDark);

  Color get canvas => isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get canvasParchment => isDark ? AppColors.mutedDark : AppColors.mutedLight;
  Color get ink => isDark ? AppColors.foregroundDark : AppColors.foregroundLight;
  Color get inkMuted80 => isDark ? AppColors.secondaryForegroundDark : AppColors.secondaryForegroundLight;
  Color get inkMuted48 => isDark ? AppColors.mutedForegroundDark : AppColors.mutedForegroundLight;
  Color get hairline => isDark ? AppColors.borderDark : AppColors.borderLight;
  
  Color get primary => isDark ? AppColors.primaryDark : AppColors.primaryLight;
  Color get onPrimary => isDark ? AppColors.primaryForegroundDark : AppColors.primaryForegroundLight;
  Color get onDark => const Color(0xFFFFFFFF);
  
  Color get statusPending => AppColors.statusPending;
  Color get statusProcessing => AppColors.statusProcessing;
  Color get statusShipped => AppColors.statusShipped;
  Color get statusDelivered => AppColors.statusDelivered;
  Color get statusCancelled => isDark ? AppColors.destructiveDark : AppColors.destructiveLight;
}
