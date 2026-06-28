// Purpose: Tests for order model display helpers.
// Main callers: flutter test.
// Key dependencies: flutter_test, OrderModel.
// Main/public functions: OrderModel display-number tests.
// Side effects: None.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/models/order_model.dart';

void main() {
  test('OrderModel uses first eight UUID characters as display number', () {
    final order = OrderModel.fromJson({
      'id': '12345678-abcd-efgh',
      'status': 'pending',
      'total': 20000,
      'created_at': '2026-06-28T00:00:00.000Z',
      'items': [],
    });

    expect(order.displayNumber, '12345678');
  });
}
