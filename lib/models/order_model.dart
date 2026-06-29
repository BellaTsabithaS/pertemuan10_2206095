// Purpose: Order data model for checkout, history, and detail screens.
// Main callers: OrderService, OrderProvider, OrderHistoryPage, OrderDetailPage.
// Key dependencies: CartItemModel.
// Main/public functions: OrderModel, OrderModel.fromJson, displayNumber.
// Side effects: None.

import 'cart_item_model.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.address,
    required this.note,
    required this.items,
  });

  final String id;
  final String status;
  final num total;
  final DateTime? createdAt;
  final String address;
  final String note;
  final List<CartItemModel> items;

  String get displayNumber => id.length <= 8 ? id : id.substring(0, 8);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['order_items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(CartItemModel.fromJson)
              .toList()
        : <CartItemModel>[];
    final parsedTotal = json['total'] is num
        ? json['total'] as num
        : num.tryParse('${json['total'] ?? ''}');
    final calculatedTotal = items.fold<num>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    return OrderModel(
      id: '${json['id'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      total: parsedTotal ?? calculatedTotal,
      createdAt: DateTime.tryParse(
        '${json['created_at'] ?? json['createdAt'] ?? ''}',
      ),
      address: '${json['address'] ?? json['shipping_address'] ?? ''}',
      note: '${json['note'] ?? json['notes'] ?? ''}',
      items: items,
    );
  }
}
