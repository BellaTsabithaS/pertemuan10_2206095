// Purpose: Tests product model persistence mapping used by product form storage.
// Main callers: flutter test.
// Key dependencies: flutter_test, ProductModel from lib/main.dart.
// Main/public functions: product model image round-trip test.
// Side effects: none; in-memory assertions only.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/main.dart';

void main() {
  test('ProductModel keeps image data through map serialization', () {
    const product = ProductModel(
      name: 'Sepatu',
      price: '120000',
      description: 'Produk contoh',
      image: 'base64-image-data',
    );

    final restored = ProductModel.fromMap(product.toMap());

    expect(restored.name, 'Sepatu');
    expect(restored.price, '120000');
    expect(restored.description, 'Produk contoh');
    expect(restored.image, 'base64-image-data');
  });
}
