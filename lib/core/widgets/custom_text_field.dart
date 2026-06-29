// Purpose: Shared custom text field for forms and search.
// Main callers: HomePage, ProfilePage.
// Key dependencies: AppColors, AppRadius, AppSpacing, AppTextStyles.

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.onSubmitted,
    this.validator,
    this.contentPadding,
    this.minLines,
    this.maxLines,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final EdgeInsetsGeometry? contentPadding;
  final int? minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      style: AppTextStyles.body.copyWith(
        fontSize: 15,
        color: context.color.ink,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.body.copyWith(
          color: context.color.inkMuted80,
          fontSize: 15,
        ),
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(
          fontSize: 15,
          color: context.color.inkMuted48,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                size: 20,
                color: context.color.inkMuted48,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.color.canvasParchment,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: context.color.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: context.color.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: context.color.primary, width: 1.5),
        ),
        errorStyle: AppTextStyles.finePrint.copyWith(
          color: context.color.statusCancelled,
        ),
      ),
    );
  }
}
