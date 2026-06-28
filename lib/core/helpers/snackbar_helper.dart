// Purpose: Shared snackbar helpers for success, error, and info feedback.
// Main callers: Feature pages after provider actions.
// Key dependencies: Flutter ScaffoldMessenger, AppColors.
// Main/public functions: showSuccessSnackBar, showErrorSnackBar, showInfoSnackBar.
// Side effects: Shows transient UI feedback through ScaffoldMessenger.

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.statusDelivered);
}

void showErrorSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.statusCancelled);
}

void showInfoSnackBar(BuildContext context, String message) {
  _showSnackBar(context, message, AppColors.primary);
}

void _showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
