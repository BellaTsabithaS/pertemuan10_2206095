// Purpose: Root app widget, provider registration, and global theme wiring.
// Main callers: main().
// Key dependencies: MaterialApp, Provider, AuthProvider, CartProvider, OrderProvider, ProductProvider, ThemeProvider, WishlistProvider, AppTheme, SplashPage.
// Main/public functions: App.
// Side effects: Starts auth/theme/wishlist state loading through providers.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/splash/splash_page.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/wishlist_provider.dart';
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
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider()..loadWishlist(),
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
