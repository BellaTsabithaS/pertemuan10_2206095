// Purpose: Cart state provider for cart item list, totals, mutations, and rollback behavior.
// Main callers: CartPage, HomePage, ProductDetailPage.
// Key dependencies: ChangeNotifier, CartService, CartItemModel, AppException.
// Main/public functions: fetchCart, addToCart, updateQuantity, removeItem, clearCart, calculateTotal.
// Side effects: Performs cart HTTP calls through CartService.

import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';
import '../core/services/cart_service.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartService? cartService})
    : _cartService = cartService ?? CartService();

  final CartService _cartService;

  List<CartItemModel> cartItems = [];
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;
  int totalItems = 0;
  num grandTotal = 0;

  Future<void> fetchCart() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      cartItems = List<CartItemModel>.of(await _cartService.fetchCart());
      calculateTotal();
    } on AppException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Gagal memuat keranjang.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(String productId, int quantity) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _cartService.addToCart(productId, quantity);
      await fetchCart();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal menambahkan ke keranjang.';
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    if (quantity < 1) {
      return false;
    }

    final index = cartItems.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      return false;
    }

    final oldItem = cartItems[index];
    cartItems[index] = oldItem.copyWith(quantity: quantity);
    calculateTotal();
    isUpdating = true;
    errorMessage = null;
    notifyListeners();

    try {
      final updated = await _cartService.updateQuantity(cartItemId, quantity);
      cartItems[index] = updated;
      calculateTotal();
      return true;
    } on AppException catch (error) {
      cartItems[index] = oldItem;
      calculateTotal();
      errorMessage = error.message;
      return false;
    } catch (_) {
      cartItems[index] = oldItem;
      calculateTotal();
      errorMessage = 'Gagal mengubah quantity.';
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> removeItem(String cartItemId) async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _cartService.removeItem(cartItemId);
      cartItems = cartItems.where((item) => item.id != cartItemId).toList();
      calculateTotal();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal menghapus item.';
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> clearCart() async {
    isUpdating = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _cartService.clearCart();
      cartItems = [];
      calculateTotal();
      return true;
    } on AppException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Gagal mengosongkan keranjang.';
      return false;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  void calculateTotal() {
    totalItems = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    grandTotal = cartItems.fold<num>(0, (sum, item) => sum + item.subtotal);
  }
}
