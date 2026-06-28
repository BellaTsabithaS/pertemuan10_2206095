// Purpose: Profile edit and dark mode settings screen.
// Main callers: HomePage.
// Key dependencies: AuthProvider, ThemeProvider, snackbar helpers.
// Main/public functions: ProfilePage.
// Side effects: Updates profile through API and persists dark mode preference.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loadedInitialValue = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user == null && auth.isAuthenticated) {
        auth.getProfile();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(
      _nameController.text.trim(),
      _phoneController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    if (success) {
      showSuccessSnackBar(context, 'Profil berhasil diperbarui.');
    } else {
      showErrorSnackBar(context, auth.errorMessage ?? 'Update profil gagal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final user = auth.user;

    if (!_loadedInitialValue && user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _loadedInitialValue = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Email', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(user?.email ?? '-'),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Nama wajib diisi.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  validator: (value) {
                    final phone = value?.trim() ?? '';
                    if (phone.isEmpty) {
                      return null;
                    }
                    return RegExp(r'^[0-9]{8,15}$').hasMatch(phone)
                        ? null
                        : 'Nomor telepon tidak valid.';
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode'),
                  value: theme.isDarkMode,
                  onChanged: (_) => theme.toggleTheme(),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: Text(
                    auth.isLoading ? 'Menyimpan...' : 'Simpan Profil',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
