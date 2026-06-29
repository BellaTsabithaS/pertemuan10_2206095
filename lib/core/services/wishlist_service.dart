// Purpose: Local wishlist storage service backed by Hive.
// Main callers: WishlistProvider.
// Key dependencies: Hive, ProductModel.
// Main/public functions: loadWishlist, saveProduct, removeProduct, contains.
// Side effects: Opens and reads/writes the wishlist_products Hive box.

import 'package:hive/hive.dart';

import '../../models/product_model.dart';

class WishlistService {
  static const boxName = 'wishlist_products';

  Future<List<ProductModel>> loadWishlist() async {
    final box = await _box();
    return box.values
        .whereType<Map>()
        .map((value) => ProductModel.fromJson(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> saveProduct(ProductModel product) async {
    final box = await _box();
    await box.put(product.id, product.toJson());
  }

  Future<void> removeProduct(String productId) async {
    final box = await _box();
    await box.delete(productId);
  }

  Future<bool> contains(String productId) async {
    final box = await _box();
    return box.containsKey(productId);
  }

  Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return Hive.openBox<dynamic>(boxName);
  }
}
