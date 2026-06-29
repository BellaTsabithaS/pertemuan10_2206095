// Purpose: Tests for admin REST service endpoint mapping and response parsing.
// Main callers: flutter test.
// Key dependencies: flutter_test, ApiService, AdminService.
// Main/public functions: admin module behavior tests.
// Side effects: None; uses fake API service instead of real HTTP.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/services/admin_service.dart';
import 'package:flutter_toko/core/services/api_service.dart';

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

  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    lastPath = path;
    lastBody = body;
    return nextResponse;
  }

  @override
  Future<dynamic> delete(String path) async {
    lastPath = path;
    return nextResponse;
  }
}

void main() {
  test('AdminService fetchStats calls dashboard stats endpoint', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {
          'total_products': 4,
          'total_orders': 5,
          'total_users': 6,
          'total_revenue': 70000,
          'orders_by_status': {'pending': 2},
        },
      };
    final service = AdminService(api: api);

    final stats = await service.fetchStats();

    expect(api.lastPath, '/dashboard/stats');
    expect(stats['total_products'], 4);
  });

  test('AdminService fetchOrders sends status page and limit query', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': [
          {'id': '12345678-abcd', 'status': 'pending', 'total': 20000},
        ],
      };
    final service = AdminService(api: api);

    final orders = await service.fetchOrders(status: 'pending', page: 2);

    expect(api.lastPath, '/orders/admin/all?status=pending&page=2&limit=10');
    expect(orders.single.displayNumber, '12345678');
  });

  test('AdminService updateOrderStatus sends status body', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {'id': '12345678-abcd', 'status': 'processing', 'total': 20000},
      };
    final service = AdminService(api: api);

    final order = await service.updateOrderStatus(
      '12345678-abcd',
      'processing',
    );

    expect(api.lastPath, '/orders/12345678-abcd/status');
    expect(api.lastBody, {'status': 'processing'});
    expect(order.status, 'processing');
  });

  test(
    'AdminService fetchOrderDetail calls admin-readable detail endpoint',
    () async {
      final api = FakeApiService()
        ..nextResponse = {
          'data': {'id': '12345678-abcd', 'status': 'pending', 'total': 20000},
        };
      final service = AdminService(api: api);

      final order = await service.fetchOrderDetail('12345678-abcd');

      expect(api.lastPath, '/orders/12345678-abcd');
      expect(order.displayNumber, '12345678');
    },
  );

  test('AdminService fetchCategories calls categories endpoint', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': [
          {'id': 'c1', 'name': 'Elektronik'},
        ],
      };
    final service = AdminService(api: api);

    final categories = await service.fetchCategories();

    expect(api.lastPath, '/categories');
    expect(categories.single.name, 'Elektronik');
  });

  test('AdminService createCategory posts category payload', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {'id': 'c1', 'name': 'Elektronik'},
      };
    final service = AdminService(api: api);

    final category = await service.createCategory(
      name: 'Elektronik',
      description: 'Perangkat elektronik',
      imageUrl: 'https://example.com/electronics.jpg',
    );

    expect(api.lastPath, '/categories');
    expect(api.lastBody, {
      'name': 'Elektronik',
      'description': 'Perangkat elektronik',
      'image_url': 'https://example.com/electronics.jpg',
    });
    expect(category.name, 'Elektronik');
  });

  test('AdminService updateCategory sends partial category payload', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {'id': 'c1', 'name': 'Elektronik Update'},
      };
    final service = AdminService(api: api);

    final category = await service.updateCategory(
      id: 'c1',
      name: 'Elektronik Update',
      description: 'Update',
      imageUrl: '',
    );

    expect(api.lastPath, '/categories/c1');
    expect(api.lastBody, {
      'name': 'Elektronik Update',
      'description': 'Update',
    });
    expect(category.name, 'Elektronik Update');
  });

  test('AdminService deleteCategory calls category delete endpoint', () async {
    final api = FakeApiService()..nextResponse = {'success': true};
    final service = AdminService(api: api);

    await service.deleteCategory('c1');

    expect(api.lastPath, '/categories/c1');
  });

  test(
    'AdminService fetchProducts calls products endpoint with pagination',
    () async {
      final api = FakeApiService()
        ..nextResponse = {
          'data': [
            {
              'id': 'p1',
              'name': 'Laptop',
              'price': 15000000,
              'stock': 7,
              'is_active': true,
              'category_id': 'c1',
            },
          ],
        };
      final service = AdminService(api: api);

      final products = await service.fetchProducts(page: 2);

      expect(api.lastPath, '/products?page=2&limit=10');
      expect(products.single.name, 'Laptop');
    },
  );

  test('AdminService createProduct posts product payload', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {
          'id': 'p1',
          'name': 'Laptop',
          'price': 15000000,
          'stock': 7,
          'is_active': true,
          'category_id': 'c1',
        },
      };
    final service = AdminService(api: api);

    final product = await service.createProduct(
      name: 'Laptop',
      description: 'Laptop gaming',
      price: 15000000,
      stock: 7,
      categoryId: 'c1',
      imageUrl: 'https://example.com/laptop.jpg',
    );

    expect(api.lastPath, '/products');
    expect(api.lastBody, {
      'name': 'Laptop',
      'description': 'Laptop gaming',
      'price': 15000000,
      'stock': 7,
      'category_id': 'c1',
      'image_url': 'https://example.com/laptop.jpg',
    });
    expect(product.name, 'Laptop');
  });

  test('AdminService updateProduct sends editable product fields', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': {
          'id': 'p1',
          'name': 'Laptop Update',
          'price': 16000000,
          'stock': 5,
          'is_active': false,
          'category_id': 'c1',
        },
      };
    final service = AdminService(api: api);

    final product = await service.updateProduct(
      id: 'p1',
      name: 'Laptop Update',
      description: '',
      price: 16000000,
      stock: 5,
      categoryId: 'c1',
      imageUrl: '',
      isActive: false,
    );

    expect(api.lastPath, '/products/p1');
    expect(api.lastBody, {
      'name': 'Laptop Update',
      'price': 16000000,
      'stock': 5,
      'category_id': 'c1',
      'is_active': false,
    });
    expect(product.isActive, isFalse);
  });

  test('AdminService deleteProduct calls product delete endpoint', () async {
    final api = FakeApiService()..nextResponse = {'success': true};
    final service = AdminService(api: api);

    await service.deleteProduct('p1');

    expect(api.lastPath, '/products/p1');
  });
}
