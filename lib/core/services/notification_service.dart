// Purpose: Local notification service for order feedback.
// Main callers: main(), CheckoutPage.
// Key dependencies: flutter_local_notifications.
// Main/public functions: NotificationService.instance, initialize, showOrderSuccess.
// Side effects: Initializes notification plugin and shows local notifications.

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    try {
      await _plugin.initialize(settings);
    } catch (_) {
      // Notification setup must not block app startup.
    }
  }

  Future<void> showOrderSuccess() async {
    const android = AndroidNotificationDetails(
      'orders',
      'Orders',
      channelDescription: 'Order status notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    try {
      await _plugin.show(
        1,
        'Pesanan Berhasil',
        'Pesanan kamu berhasil dibuat. Cek riwayat pesanan untuk melihat detailnya.',
        details,
      );
    } catch (_) {
      // Denied or unsupported notifications must not block checkout success UI.
    }
  }
}
