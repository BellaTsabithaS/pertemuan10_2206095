// Purpose: Radius tokens mapped from DESIGN.md.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter BorderRadius.
// Main/public functions: AppRadius.
// Side effects: None.

import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double none = 0;
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 11;
  static const double lg = 18;
  static const double pill = 9999;

  static BorderRadius circular(double value) => BorderRadius.circular(value);
}
