// Purpose: Light and dark ThemeData built from DESIGN.md tokens.
// Main callers: App.
// Key dependencies: AppColors, AppRadius, AppTextStyles.
// Main/public functions: AppTheme.light, AppTheme.dark.
// Side effects: None.

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _base(
    brightness: Brightness.light,
    scaffoldBackground: AppColors.canvasParchment,
    surface: AppColors.canvas,
    textColor: AppColors.ink,
  );

  static ThemeData get dark => _base(
    brightness: Brightness.dark,
    scaffoldBackground: AppColors.surfaceTile1,
    surface: AppColors.surfaceTile2,
    textColor: AppColors.bodyOnDark,
  );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color surface,
    required Color textColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.displayLarge,
        titleMedium: AppTextStyles.tagline,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.caption,
        labelLarge: AppTextStyles.captionStrong,
      ).apply(bodyColor: textColor, displayColor: textColor),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.primaryFocus, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
    );
  }
}
