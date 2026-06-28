// Purpose: Register form for customer account creation.
// Main callers: LoginPage.
// Key dependencies: AuthProvider, snackbar helpers.
// Main/public functions: RegisterPage.
// Side effects: Sends register request through AuthProvider and returns to LoginPage after success.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) {
      return;
    }
    if (success) {
      showSuccessSnackBar(context, 'Register berhasil. Silakan login.');
      Navigator.of(context).pop();
    } else {
      showErrorSnackBar(context, auth.errorMessage ?? 'Register gagal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Nama wajib diisi.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return !email.contains('@') || !email.contains('.')
                        ? 'Email tidak valid.'
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => (value ?? '').length < 6
                      ? 'Password minimal 6 karakter.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: Text(auth.isLoading ? 'Memproses...' : 'Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
