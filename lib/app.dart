// Purpose: Root Flutter app widget during initial rebuild.
// Main callers: main().
// Key dependencies: MaterialApp.
// Main/public functions: App.
// Side effects: None.

import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Flutter E-Commerce UAS')),
      ),
    );
  }
}
