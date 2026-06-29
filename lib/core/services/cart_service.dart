// Purpose: Cart REST service for fetching, adding, updating, removing, and clearing cart items.
// Main callers: CartProvider.
// Key dependencies: ApiService, CartItemModel.
// Main/public functions: fetchCart, addToCart, updateQuantity, removeItem, clearCart.
// Side effects: Performs HTTP requests through ApiService.

import '../../models/cart_item_model.dart';
import 'api_service.dart';

class CartService {
  CartService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<CartItemModel>> fetchCart() async {
    final response = await _api.get('/cart');
    return _extractList(response).map(CartItemModel.fromJson).toList();
  }

  Future<void> addToCart(String productId, int quantity) async {
    await _api.post(
      '/cart',
      body: {'product_id': productId, 'quantity': quantity},
    );
  }

  Future<CartItemModel> updateQuantity(String cartItemId, int quantity) async {
    final response = await _api.put(
      '/cart/$cartItemId',
      body: {'quantity': quantity},
    );
    return CartItemModel.fromJson(_extractMap(response));
  }

  Future<void> removeItem(String cartItemId) async {
    await _api.delete('/cart/$cartItemId');
  }

  Future<void> clearCart() async {
    await _api.delete('/cart');
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      if (data is Map<String, dynamic> && data['items'] is List) {
        return (data['items'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (response['items'] is List) {
        return (response['items'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (response['cart'] is List) {
        return (response['cart'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      final item = response['item'];
      if (item is Map<String, dynamic>) {
        return item;
      }
      return response;
    }
    return <String, dynamic>{};
  }
}
