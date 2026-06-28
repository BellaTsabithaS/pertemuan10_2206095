// Purpose: Tests for DESIGN.md-derived theme token wiring.
// Main callers: flutter test.
// Key dependencies: flutter_test, AppTheme, AppColors, AppRadius.
// Main/public functions: theme token tests.
// Side effects: None.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/theme/app_colors.dart';
import 'package:flutter_toko/core/theme/app_radius.dart';
import 'package:flutter_toko/core/theme/app_theme.dart';

void main() {
  test('light theme uses Apple-style primary and parchment canvas', () {
    final theme = AppTheme.light;

    expect(theme.colorScheme.primary, AppColors.primary);
    expect(theme.scaffoldBackgroundColor, AppColors.canvasParchment);
  });

  test('dark theme uses near-black canvas', () {
    final theme = AppTheme.dark;

    expect(theme.scaffoldBackgroundColor, AppColors.surfaceTile1);
    expect(theme.brightness, Brightness.dark);
  });

  test('card theme uses utility card radius and no elevation', () {
    final theme = AppTheme.light;
    final shape = theme.cardTheme.shape;

    expect(theme.cardTheme.elevation, 0);
    expect(shape, isA<RoundedRectangleBorder>());
    final border = shape as RoundedRectangleBorder;
    expect(border.borderRadius, BorderRadius.circular(AppRadius.lg));
  });
}
