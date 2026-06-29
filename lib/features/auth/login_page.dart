// Purpose: Login form for customer and admin authentication.
// Main callers: SplashPage, RegisterPage, logout flow.
// Key dependencies: AuthProvider, AdminHomePage, HomePage, RegisterPage, snackbar helpers.
// Main/public functions: LoginPage.
// Side effects: Saves token through AuthProvider and navigates by user role after success.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_home_page.dart';
import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      final page = auth.user?.isAdmin == true
          ? const AdminHomePage()
          : const HomePage();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => page));
    } else {
      showErrorSnackBar(context, auth.errorMessage ?? 'Login gagal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: context.color.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Header ---
                  _buildHeader(),

                  const SizedBox(height: AppSpacing.lg),

                  // --- Form ---
                  _buildForm(auth),

                  const SizedBox(height: AppSpacing.md),

                  // --- Register link ---
                  _buildRegisterLink(auth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Masuk',
          textAlign: TextAlign.center,
          style: AppTextStyles.displayLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Masukkan email dan password kamu\nuntuk melanjutkan.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: context.color.inkMuted48),
        ),
      ],
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email
          _ShadLabel(label: 'Email'),
          const SizedBox(height: AppSpacing.xs),
          CustomTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            hintText: 'nama@email.com',
            validator: _validateEmail,
          ),

          const SizedBox(height: AppSpacing.md),

          // Password
          _ShadLabel(label: 'Password'),
          const SizedBox(height: AppSpacing.xs),
          CustomTextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => auth.isLoading ? null : _submit(),
            hintText: 'Min. 6 karakter',
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 16,
                color: context.color.inkMuted48,
              ),
            ),
            validator: _validatePassword,
          ),

          const SizedBox(height: AppSpacing.xl),

          // Submit
          CustomButton(
            onPressed: auth.isLoading ? null : _submit,
            text: 'Masuk',
            isLoading: auth.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(AuthProvider auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun?',
          style: AppTextStyles.finePrint.copyWith(
            color: context.color.inkMuted48,
          ),
        ),
        TextButton(
          onPressed: auth.isLoading
              ? null
              : () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const RegisterPage())),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Daftar',
            style: AppTextStyles.finePrint.copyWith(
              color: context.color.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Email tidak valid.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').length < 6) {
      return 'Password minimal 6 karakter.';
    }
    return null;
  }
}

// Shadcn-style field label.
class _ShadLabel extends StatelessWidget {
  const _ShadLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.captionStrong.copyWith(
        fontSize: 13,
        color: context.color.ink,
      ),
    );
  }
}
