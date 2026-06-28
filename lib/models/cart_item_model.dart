// Purpose: Cart item model for cart and order item rows.
// Main callers: CartProvider, OrderModel, CartPage, OrderDetailPage.
// Key dependencies: ProductModel.
// Main/public functions: CartItemModel, CartItemModel.fromJson, subtotal.
// Side effects: None.

import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final ProductModel product;
  final int quantity;

  num get subtotal => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final productMap = productJson is Map<String, dynamic> ? productJson : json;

    return CartItemModel(
      id: '${json['id'] ?? ''}',
      product: ProductModel.fromJson(productMap),
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse('${json['quantity'] ?? 1}') ?? 1,
    );
  }
}
