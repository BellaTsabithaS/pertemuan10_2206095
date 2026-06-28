// Purpose: Color tokens mapped from DESIGN.md for the e-commerce app.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter Color.
// Main/public functions: AppColors.
// Side effects: None.

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF0066CC);
  static const primaryFocus = Color(0xFF0071E3);
  static const primaryOnDark = Color(0xFF2997FF);
  static const ink = Color(0xFF1D1D1F);
  static const body = Color(0xFF1D1D1F);
  static const bodyOnDark = Color(0xFFFFFFFF);
  static const bodyMuted = Color(0xFFCCCCCC);
  static const inkMuted80 = Color(0xFF333333);
  static const inkMuted48 = Color(0xFF7A7A7A);
  static const dividerSoft = Color(0xFFF0F0F0);
  static const hairline = Color(0xFFE0E0E0);
  static const canvas = Color(0xFFFFFFFF);
  static const canvasParchment = Color(0xFFF5F5F7);
  static const surfacePearl = Color(0xFFFAFAFC);
  static const surfaceTile1 = Color(0xFF272729);
  static const surfaceTile2 = Color(0xFF2A2A2C);
  static const surfaceTile3 = Color(0xFF252527);
  static const surfaceBlack = Color(0xFF000000);
  static const surfaceChipTranslucent = Color(0xA3D2D2D7);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onDark = Color(0xFFFFFFFF);

  static const statusPending = Color(0xFFB7791F);
  static const statusProcessing = Color(0xFF0066CC);
  static const statusShipped = Color(0xFF6B46C1);
  static const statusDelivered = Color(0xFF2F855A);
  static const statusCancelled = Color(0xFFC53030);
}
