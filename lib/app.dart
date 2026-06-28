// Purpose: Root app widget, provider registration, and global theme wiring.
// Main callers: main().
// Key dependencies: MaterialApp, Provider, AuthProvider, ThemeProvider, AppTheme, SplashPage.
// Main/public functions: App.
// Side effects: None.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/splash/splash_page.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkLoginStatus(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter E-Commerce UAS',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
