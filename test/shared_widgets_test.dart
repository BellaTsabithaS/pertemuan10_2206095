// Purpose: Tests for shared state widgets used by feature pages.
// Main callers: flutter test.
// Key dependencies: flutter_test, MaterialApp, EmptyStateWidget.
// Main/public functions: EmptyStateWidget rendering tests.
// Side effects: Pumps Flutter widgets in the test environment.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/widgets/empty_state_widget.dart';

void main() {
  testWidgets('EmptyStateWidget renders message and action', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyStateWidget(
            title: 'Keranjang kosong',
            message: 'Cari produk dulu.',
            actionLabel: 'Belanja',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Keranjang kosong'), findsOneWidget);
    expect(find.text('Cari produk dulu.'), findsOneWidget);

    await tester.tap(find.text('Belanja'));

    expect(tapped, isTrue);
  });
}
