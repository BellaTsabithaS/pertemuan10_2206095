// Purpose: Startup gate that chooses login or authenticated home based on auth state.
// Main callers: App MaterialApp.home.
// Key dependencies: AuthProvider, LoginPage, HomePage, LoadingWidget.
// Main/public functions: SplashPage.
// Side effects: None.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/loading_widget.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_page.dart';
import '../home/home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(body: LoadingWidget(message: 'Memuat sesi...'));
        }

        if (authProvider.isAuthenticated) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}
