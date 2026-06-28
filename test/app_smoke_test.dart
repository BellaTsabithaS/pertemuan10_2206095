// Purpose: Smoke test for the rebuilt Flutter auth app shell.
// Main callers: flutter test.
// Key dependencies: flutter_test, SharedPreferences mock store, App.
// Main/public functions: app shell widget test.
// Side effects: Pumps Flutter widgets in the test environment.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login page when app starts without token', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsWidgets);
  });
}
