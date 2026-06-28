// Purpose: Temporary notification service shell used during app bootstrap.
// Main callers: main(); checkout flow will use this service in the notification module.
// Key dependencies: None for the foundation phase.
// Main/public functions: NotificationService.instance, initialize.
// Side effects: None until notification channel setup is added.

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  Future<void> initialize() async {}
}
