// Purpose: Smoke test for the rebuilt Flutter app shell.
// Main callers: flutter test.
// Key dependencies: flutter_test, App.
// Main/public functions: app shell widget test.
// Side effects: Pumps Flutter widgets in the test environment.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/app.dart';

void main() {
  testWidgets('shows ecommerce app shell title', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Flutter E-Commerce UAS'), findsOneWidget);
  });
}
