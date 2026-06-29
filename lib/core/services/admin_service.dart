// Purpose: Admin REST service for dashboard, admin orders, status updates, category CRUD, and product CRUD.
// Main callers: AdminProvider.
// Key dependencies: ApiService, CategoryModel, OrderModel, ProductModel.
// Main/public functions: fetchStats, fetchLowStock, fetchTopProducts, fetchRecentOrders, fetchOrders, fetchOrderDetail, updateOrderStatus, fetchCategories, createCategory, updateCategory, deleteCategory, fetchProducts, createProduct, updateProduct, deleteProduct.
// Side effects: Performs authenticated admin HTTP requests through ApiService.

import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import 'api_service.dart';

class AdminService {
  AdminService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<Map<String, dynamic>> fetchStats() async {
    final response = await _api.get('/dashboard/stats');
    return _extractMap(response);
  }

  Future<List<Map<String, dynamic>>> fetchLowStock({int threshold = 10}) async {
    final response = await _api.get(
      '/dashboard/low-stock?threshold=$threshold',
    );
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> fetchTopProducts({int limit = 5}) async {
    final response = await _api.get('/dashboard/top-products?limit=$limit');
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> fetchRecentOrders({int limit = 5}) async {
    final response = await _api.get('/dashboard/recent-orders?limit=$limit');
    return _extractList(response);
  }

  Future<List<OrderModel>> fetchOrders({
    String status = '',
    int page = 1,
  }) async {
    final query = Uri(
      queryParameters: {
        if (status.isNotEmpty) 'status': status,
        'page': '$page',
        'limit': '10',
      },
    ).query;
    final response = await _api.get('/orders/admin/all?$query');
    return _extractList(response).map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    final response = await _api.put(
      '/orders/$orderId/status',
      body: {'status': status},
    );
    return OrderModel.fromJson(_extractMap(response));
  }

  Future<OrderModel> fetchOrderDetail(String orderId) async {
    final response = await _api.get('/orders/$orderId');
    return OrderModel.fromJson(_extractMap(response));
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _api.get('/categories');
    return _extractList(response).map(CategoryModel.fromJson).toList();
  }

  Future<CategoryModel> createCategory({
    required String name,
    String description = '',
    String imageUrl = '',
  }) async {
    final response = await _api.post(
      '/categories',
      body: {
        'name': name,
        if (description.isNotEmpty) 'description': description,
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
      },
    );
    return CategoryModel.fromJson(_extractMap(response));
  }

  Future<CategoryModel> updateCategory({
    required String id,
    required String name,
    String description = '',
    String imageUrl = '',
  }) async {
    final response = await _api.put(
      '/categories/$id',
      body: {
        'name': name,
        if (description.isNotEmpty) 'description': description,
        if (imageUrl.isNotEmpty) 'image_url': imageUrl,
      },
    );
    return CategoryModel.fromJson(_extractMap(response));
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete('/categories/$id');
  }

  Future<List<ProductModel>> fetchProducts({int page = 1}) async {
    final query = Uri(queryParameters: {'page': '$page', 'limit': '10'}).query;
    final response = await _api.get('/products?$query');
    return _extractList(response).map(ProductModel.fromJson).toList();
  }

  Future<ProductModel> createProduct({
    required String name,
    required num price,
    required int stock,
    required String categoryId,
    String description = '',
    String imageUrl = '',
  }) async {
    final response = await _api.post(
      '/products',
      body: _productBody(
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        imageUrl: imageUrl,
      ),
    );
    return ProductModel.fromJson(_extractMap(response));
  }

  Future<ProductModel> updateProduct({
    required String id,
    required String name,
    required num price,
    required int stock,
    required String categoryId,
    required bool isActive,
    String description = '',
    String imageUrl = '',
  }) async {
    final response = await _api.put(
      '/products/$id',
      body: {
        ..._productBody(
          name: name,
          description: description,
          price: price,
          stock: stock,
          categoryId: categoryId,
          imageUrl: imageUrl,
        ),
        'is_active': isActive,
      },
    );
    return ProductModel.fromJson(_extractMap(response));
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete('/products/$id');
  }

  Map<String, dynamic> _productBody({
    required String name,
    required num price,
    required int stock,
    required String categoryId,
    required String description,
    required String imageUrl,
  }) {
    return {
      'name': name,
      if (description.isNotEmpty) 'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      if (imageUrl.isNotEmpty) 'image_url': imageUrl,
    };
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
      return response;
    }
    return <String, dynamic>{};
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
        for (final key in ['orders', 'products', 'items', 'data']) {
          final value = data[key];
          if (value is List) {
            return value.whereType<Map<String, dynamic>>().toList();
          }
        }
      }
    }
    return <Map<String, dynamic>>[];
  }
}
