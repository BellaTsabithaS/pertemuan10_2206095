// Purpose: Product REST service for catalog, category, and detail flows.
// Main callers: ProductProvider.
// Key dependencies: ApiService, ProductModel, CategoryModel.
// Main/public functions: fetchProducts, fetchCategories, fetchProductDetail.
// Side effects: Performs HTTP GET requests through ApiService.

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  ProductService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<List<ProductModel>> fetchProducts({
    String search = '',
    String category = '',
    String sort = '',
    int page = 1,
  }) async {
    final query = Uri(
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (category.isNotEmpty) 'category': category,
        if (sort.isNotEmpty) 'sort': sort,
        'page': '$page',
      },
    ).query;
    final response = await _api.get('/products?$query');
    return _extractList(response).map(ProductModel.fromJson).toList();
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _api.get('/categories');
    return _extractList(response).map(CategoryModel.fromJson).toList();
  }

  Future<ProductModel> fetchProductDetail(String id) async {
    final response = await _api.get('/products/$id');
    return ProductModel.fromJson(_extractMap(response));
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
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      if (response['products'] is List) {
        return (response['products'] as List)
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
      final product = response['product'];
      if (product is Map<String, dynamic>) {
        return product;
      }
      return response;
    }
    return <String, dynamic>{};
  }
}
