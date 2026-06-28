// Purpose: Temporary authenticated landing page until product catalog module fills Home.
// Main callers: SplashPage, LoginPage.
// Key dependencies: AuthProvider, ProfilePage, AppTextStyles.
// Main/public functions: HomePage.
// Side effects: Can trigger logout through AuthProvider from user action.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Katalog produk akan dibuat di module berikutnya.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ),
      ),
    );
  }
}
