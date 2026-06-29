import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.color.primary,
        foregroundColor: Colors.white, // Enforce white text
        disabledBackgroundColor: context.color.inkMuted48,
        disabledForegroundColor: Colors.white.withAlpha(180),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circular(AppRadius.sm),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: AppTextStyles.bodyStrong.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
