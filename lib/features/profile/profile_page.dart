// Purpose: Profile edit and dark mode settings screen.
// Main callers: HomePage (IndexedStack tab 4).
// Key dependencies: AuthProvider, ThemeProvider, snackbar helpers.
// Main/public functions: ProfilePage.
// Side effects: Updates profile through API and persists dark mode preference.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/helpers/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
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
      backgroundColor: context.color.canvas,
      appBar: AppBar(
        backgroundColor: context.color.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profil',
          style: AppTextStyles.tagline.copyWith(
            color: context.color.ink,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: context.color.hairline),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Akun Label
                Text(
                  'Info Akun',
                  style: AppTextStyles.bodyStrong.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Read-only email
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.color.canvasParchment,
                    borderRadius: AppRadius.circular(AppRadius.sm),
                    border: Border.all(color: context.color.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, color: AppColors.inkMuted48, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          user?.email ?? '-',
                          style: AppTextStyles.body.copyWith(
                            color: context.color.inkMuted80,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(Icons.lock_outline, color: AppColors.inkMuted48, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Inputs
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icons.person_outline,
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Nama wajib diisi.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                CustomTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icons.phone_outlined,
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
                const SizedBox(height: AppSpacing.xl),

                // Pengaturan Label
                Text(
                  'Pengaturan',
                  style: AppTextStyles.bodyStrong.copyWith(color: context.color.ink),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Theme Toggle
                Container(
                  decoration: BoxDecoration(
                    color: context.color.canvas,
                    borderRadius: AppRadius.circular(AppRadius.sm),
                    border: Border.all(color: context.color.hairline),
                  ),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: AppTextStyles.body.copyWith(
                        color: context.color.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    secondary: Icon(
                      Icons.dark_mode_outlined,
                      color: context.color.inkMuted48,
                    ),
                    activeThumbColor: context.color.primary,
                    activeTrackColor: context.color.primary.withAlpha(51),
                    value: theme.isDarkMode,
                    onChanged: (_) => theme.toggleTheme(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Buttons
                CustomButton(
                  onPressed: auth.isLoading ? null : _submit,
                  text: 'Simpan Profil',
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () async {
                    await auth.logout();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.color.statusCancelled,
                    side: BorderSide(color: context.color.hairline),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: AppTextStyles.bodyStrong.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
