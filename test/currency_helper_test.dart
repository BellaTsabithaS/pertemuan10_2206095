// Purpose: Tests for currency helper output used by product, cart, and order UI.
// Main callers: flutter test.
// Key dependencies: flutter_test, currency_helper.
// Main/public functions: formatRupiah test.
// Side effects: None.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/helpers/currency_helper.dart';

void main() {
  test('formatRupiah formats whole numbers for Indonesian currency', () {
    expect(formatRupiah(12000), 'Rp 12.000');
  });
}
