// Purpose: Register form for customer account creation.
// Main callers: LoginPage.
// Key dependencies: AuthProvider, snackbar helpers.
// Main/public functions: RegisterPage.
// Side effects: Sends register request through AuthProvider and returns to LoginPage after success.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterPage
    extends
        StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<
    RegisterPage
  >
  createState() => _RegisterPageState();
}

class _RegisterPageState
    extends
        State<
          RegisterPage
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context
        .read<
          AuthProvider
        >();
    final success = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      showSuccessSnackBar(
        context,
        'Register berhasil. Silakan login.',
      );
      Navigator.of(
        context,
      ).pop();
    } else {
      showErrorSnackBar(
        context,
        auth.errorMessage ??
            'Register gagal.',
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final auth = context
        .watch<
          AuthProvider
        >();

    return Scaffold(
      backgroundColor: context.color.canvas,
      // Custom back button, no title in AppBar
      appBar: AppBar(
        backgroundColor: context.color.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
          ),
          color: context.color.ink,
          onPressed: () => Navigator.of(
            context,
          ).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Header ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Buat Akun',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.xs,
                      ),
                      Text(
                        'Isi data di bawah untuk\nmembuat akun baru.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: context.color.inkMuted48,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppSpacing.xl,
                  ),

                  // --- Form ---
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name
                        _FieldLabel(
                          label: 'Nama Lengkap',
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        CustomTextField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          hintText: 'Nama kamu',
                          validator: (value) => (value?.trim().isEmpty ?? true)
                              ? 'Nama wajib diisi.'
                              : null,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Email
                        _FieldLabel(label: 'Email'),
                        const SizedBox(height: AppSpacing.xs),
                        CustomTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          hintText: 'nama@email.com',
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            return !email.contains('@') || !email.contains('.')
                                ? 'Email tidak valid.'
                                : null;
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Password
                        _FieldLabel(label: 'Password'),
                        const SizedBox(height: AppSpacing.xs),
                        CustomTextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => auth.isLoading ? null : _submit(),
                          hintText: 'Min. 6 karakter',
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 16,
                              color: context.color.inkMuted48,
                            ),
                          ),
                          validator: (value) => (value ?? '').length < 6
                              ? 'Password minimal 6 karakter.'
                              : null,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Submit
                        CustomButton(
                          onPressed: auth.isLoading ? null : _submit,
                          text: 'Buat Akun',
                          isLoading: auth.isLoading,
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun?',
                              style: AppTextStyles.finePrint.copyWith(
                                color: context.color.inkMuted48,
                              ),
                            ),
                            TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () => Navigator.of(
                                      context,
                                    ).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Masuk',
                                style: AppTextStyles.finePrint.copyWith(
                                  color: context.color.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Internal widget: field label above each input.
class _FieldLabel
    extends
        StatelessWidget {
  const _FieldLabel({
    required this.label,
  });
  final String label;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      label,
      style: AppTextStyles.captionStrong.copyWith(
        fontSize: 13,
        color: context.color.ink,
      ),
    );
  }
}
