// Purpose: Order REST service for checkout, order history, and order detail.
// Main callers: OrderProvider.
// Key dependencies: ApiService, OrderModel.
// Main/public functions: checkout, fetchOrders, fetchOrderDetail.
// Side effects: Performs HTTP requests through ApiService.

import '../../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  OrderService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<OrderModel> checkout(String address, String note) async {
    final response = await _api.post(
      '/orders',
      body: {'shipping_address': address, 'notes': note},
    );
    return OrderModel.fromJson(_extractMap(response));
  }

  Future<List<OrderModel>> fetchOrders({int page = 1}) async {
    final query = Uri(queryParameters: {'page': '$page', 'limit': '10'}).query;
    final response = await _api.get('/orders?$query');
    return _extractList(response).map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> fetchOrderDetail(String id) async {
    final response = await _api.get('/orders/$id');
    return OrderModel.fromJson(_extractMap(response));
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
      if (data is Map<String, dynamic>) {
        final orders = data['orders'];
        if (orders is List) {
          return orders.whereType<Map<String, dynamic>>().toList();
        }
        final items = data['items'];
        if (items is List) {
          return items.whereType<Map<String, dynamic>>().toList();
        }
      }
      final orders = response['orders'];
      if (orders is List) {
        return orders.whereType<Map<String, dynamic>>().toList();
      }
    }
    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final order = data['order'];
        if (order is Map<String, dynamic>) {
          return order;
        }
        return data;
      }
      final order = response['order'];
      if (order is Map<String, dynamic>) {
        return order;
      }
      return response;
    }
    return <String, dynamic>{};
  }
}
