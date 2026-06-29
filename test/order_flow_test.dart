// Purpose: Tests for order checkout service/provider behavior.
// Main callers: flutter test.
// Key dependencies: flutter_test, ApiService, OrderService, OrderProvider, OrderModel.
// Main/public functions: order module behavior tests.
// Side effects: None; uses fakes instead of real HTTP.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/exceptions/app_exception.dart';
import 'package:flutter_toko/core/services/api_service.dart';
import 'package:flutter_toko/core/services/order_service.dart';
import 'package:flutter_toko/models/order_model.dart';
import 'package:flutter_toko/providers/order_provider.dart';

class FakeApiService extends ApiService {
  String? lastPath;
  Map<String, dynamic>? lastBody;
  dynamic nextResponse;

  @override
  Future<dynamic> get(String path) async {
    lastPath = path;
    return nextResponse;
  }

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    lastPath = path;
    lastBody = body;
    return nextResponse;
  }
}

class FakeOrderService extends OrderService {
  FakeOrderService({this.shouldThrow = false}) : super(api: FakeApiService());

  final bool shouldThrow;

  @override
  Future<OrderModel> checkout(String address, String note) async {
    if (shouldThrow) {
      throw const AppException('Checkout gagal.');
    }
    return OrderModel.fromJson({
      'id': '12345678-abcd-efgh',
      'status': 'pending',
      'total': 20000,
      'shipping_address': address,
      'notes': note,
      'items': [],
    });
  }

  @override
  Future<List<OrderModel>> fetchOrders({int page = 1}) async {
    return [
      OrderModel.fromJson({
        'id': '87654321-abcd-efgh',
        'status': 'processing',
        'total': 30000,
        'items': [],
      }),
    ];
  }
}

void main() {
  test('OrderService checkout posts shipping address and notes', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {
          'id': '12345678-abcd-efgh',
          'status': 'pending',
          'total': 20000,
          'shipping_address': 'Jl. Merdeka No. 123',
          'notes': 'Packing aman',
          'items': [],
        },
      };
    final service = OrderService(api: api);

    final order = await service.checkout('Jl. Merdeka No. 123', 'Packing aman');

    expect(order.displayNumber, '12345678');
    expect(api.lastPath, '/orders');
    expect(api.lastBody, {
      'shipping_address': 'Jl. Merdeka No. 123',
      'notes': 'Packing aman',
    });
  });

  test('OrderService fetchOrders sends page and limit query', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': [
          {'id': '87654321-abcd-efgh', 'status': 'pending', 'total': 20000},
        ],
      };
    final service = OrderService(api: api);

    final orders = await service.fetchOrders(page: 2);

    expect(orders.single.displayNumber, '87654321');
    expect(api.lastPath, '/orders?page=2&limit=10');
  });

  test('OrderProvider checkout stores selected order on success', () async {
    final provider = OrderProvider(orderService: FakeOrderService());

    final success = await provider.checkout(
      'Jl. Merdeka No. 123',
      'Packing aman',
    );

    expect(success, isTrue);
    expect(provider.selectedOrder?.displayNumber, '12345678');
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('OrderProvider checkout keeps error message on failure', () async {
    final provider = OrderProvider(
      orderService: FakeOrderService(shouldThrow: true),
    );

    final success = await provider.checkout(
      'Jl. Merdeka No. 123',
      'Packing aman',
    );

    expect(success, isFalse);
    expect(provider.selectedOrder, isNull);
    expect(provider.isLoading, isFalse);
    expect(provider.errorMessage, 'Checkout gagal.');
  });
}
