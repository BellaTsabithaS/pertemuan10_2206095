// Purpose: Tests for defensive product model parsing.
// Main callers: flutter test.
// Key dependencies: flutter_test, ProductModel.
// Main/public functions: ProductModel parsing tests.
// Side effects: None.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/models/product_model.dart';

void main() {
  test('ProductModel parses missing optional fields safely', () {
    final product = ProductModel.fromJson({
      'id': 'p1',
      'name': 'Laptop',
      'price': 12000000,
    });

    expect(product.id, 'p1');
    expect(product.name, 'Laptop');
    expect(product.price, 12000000);
    expect(product.imageUrl, '');
    expect(product.stock, 0);
  });
}
