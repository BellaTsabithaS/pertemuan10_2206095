// Purpose: Tests for product service, provider state, and product card UI.
// Main callers: flutter test.
// Key dependencies: flutter_test, ProductService, ProductProvider, ProductCard.
// Main/public functions: product module behavior tests.
// Side effects: Pumps Flutter widgets in the test environment.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/services/api_service.dart';
import 'package:flutter_toko/core/services/product_service.dart';
import 'package:flutter_toko/core/widgets/product_card.dart';
import 'package:flutter_toko/models/product_model.dart';
import 'package:flutter_toko/providers/product_provider.dart';

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

void main() {
  test(
    'ProductService fetchProducts sends search filter sort and page',
    () async {
      final api = FakeApiService()
        ..nextResponse = {
          'data': [
            {'id': 'p1', 'name': 'Laptop', 'price': 12000000},
          ],
        };
      final service = ProductService(api: api);

      final products = await service.fetchProducts(
        search: 'laptop',
        category: 'c1',
        sort: 'price_asc',
        page: 2,
      );

      expect(products.single.name, 'Laptop');
      expect(
        api.lastPath,
        '/products?search=laptop&category_id=c1&sort=price_asc&page=2',
      );
    },
  );

  test('ProductProvider searchProducts refreshes first page state', () async {
    final api = FakeApiService()
      ..nextResponse = {
        'data': [
          {'id': 'p1', 'name': 'Laptop', 'price': 12000000},
        ],
      };
    final provider = ProductProvider(productService: ProductService(api: api));

    await provider.searchProducts('laptop');

    expect(provider.searchQuery, 'laptop');
    expect(provider.currentPage, 1);
    expect(provider.products.single.id, 'p1');
    expect(provider.isLoading, isFalse);
  });

  testWidgets('ProductCard renders product data and handles taps', (
    tester,
  ) async {
    var opened = false;
    var wishlisted = false;
    const product = ProductModel(
      id: 'p1',
      name: 'Laptop',
      price: 12000000,
      description: '',
      imageUrl: '',
      categoryId: 'c1',
      categoryName: 'Elektronik',
      stock: 5,
      rating: 4.5,
      reviewCount: 2,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            isWishlisted: false,
            onTap: () => opened = true,
            onWishlistTap: () => wishlisted = true,
          ),
        ),
      ),
    );

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Rp 12.000.000'), findsOneWidget);

    await tester.tap(find.text('Laptop'));
    await tester.tap(find.byIcon(Icons.favorite_border));

    expect(opened, isTrue);
    expect(wishlisted, isTrue);
  });
}
