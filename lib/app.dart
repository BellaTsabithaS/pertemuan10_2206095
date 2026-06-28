// Purpose: Root app widget and global theme wiring.
// Main callers: main().
// Key dependencies: MaterialApp, AppTheme.
// Main/public functions: App.
// Side effects: None.

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter E-Commerce UAS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(
        body: Center(child: Text('Flutter E-Commerce UAS')),
      ),
    );
  }
}
