// Purpose: Wishlist state provider for local wishlist products.
// Main callers: HomePage, ProductDetailPage, WishlistPage.
// Key dependencies: ChangeNotifier, WishlistService, ProductModel.
// Main/public functions: loadWishlist, addWishlist, removeWishlist, toggleWishlist, isWishlisted.
// Side effects: Reads and writes local Hive wishlist through WishlistService.

import 'package:flutter/foundation.dart';

import '../core/services/wishlist_service.dart';
import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider({WishlistService? wishlistService})
    : _wishlistService = wishlistService ?? WishlistService();

  final WishlistService _wishlistService;

  List<ProductModel> wishlistProducts = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadWishlist() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      wishlistProducts = await _wishlistService.loadWishlist();
    } catch (_) {
      errorMessage = 'Gagal memuat wishlist.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addWishlist(ProductModel product) async {
    try {
      await _wishlistService.saveProduct(product);
      wishlistProducts = [
        ...wishlistProducts.where((item) => item.id != product.id),
        product,
      ];
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Gagal menambahkan wishlist.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeWishlist(String productId) async {
    try {
      await _wishlistService.removeProduct(productId);
      wishlistProducts = wishlistProducts
          .where((item) => item.id != productId)
          .toList();
      errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Gagal menghapus wishlist.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleWishlist(ProductModel product) async {
    if (isWishlisted(product.id)) {
      return removeWishlist(product.id);
    }
    return addWishlist(product);
  }

  bool isWishlisted(String productId) {
    return wishlistProducts.any((product) => product.id == productId);
  }
}
