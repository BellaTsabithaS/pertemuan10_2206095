// Purpose: Flutter app bootstrap for the e-commerce UAS app.
// Main callers: Flutter runtime via main().
// Key dependencies: Hive Flutter, NotificationService, App.
// Main/public functions: main.
// Side effects: Initializes Hive storage and local notification plumbing before runApp().

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService.instance.initialize();
  runApp(const App());
}
