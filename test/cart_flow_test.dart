// Purpose: Tests for cart service, provider state, rollback, and cart page empty state.
// Main callers: flutter test.
// Key dependencies: flutter_test, provider, CartService, CartProvider, CartPage.
// Main/public functions: cart module behavior tests.
// Side effects: Pumps Flutter widgets in the test environment.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/services/api_service.dart';
import 'package:flutter_toko/core/services/cart_service.dart';
import 'package:flutter_toko/features/cart/cart_page.dart';
import 'package:flutter_toko/models/cart_item_model.dart';
import 'package:flutter_toko/models/product_model.dart';
import 'package:flutter_toko/providers/cart_provider.dart';
import 'package:provider/provider.dart';

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

class FakeCartService extends CartService {
  FakeCartService({this.items = const [], this.failUpdate = false})
    : super(api: FakeApiService());

  List<CartItemModel> items;
  bool failUpdate;

  @override
  Future<List<CartItemModel>> fetchCart() async => items;

  @override
  Future<void> addToCart(String productId, int quantity) async {}

  @override
  Future<CartItemModel> updateQuantity(String cartItemId, int quantity) async {
    if (failUpdate) {
      throw Exception('failed');
    }
    final index = items.indexWhere((item) => item.id == cartItemId);
    final updated = items[index].copyWith(quantity: quantity);
    items[index] = updated;
    return updated;
  }

  @override
  Future<void> removeItem(String cartItemId) async {
    items = items.where((item) => item.id != cartItemId).toList();
  }

  @override
  Future<void> clearCart() async {
    items = [];
  }
}

void main() {
  const product = ProductModel(
    id: 'p1',
    name: 'Laptop',
    price: 12000000,
    description: '',
    imageUrl: '',
    categoryId: 'c1',
    categoryName: 'Elektronik',
    stock: 5,
    isActive: true,
    rating: 4.5,
    reviewCount: 2,
  );

  test('CartService addToCart posts product id and quantity', () async {
    final api = FakeApiService()..nextResponse = {'ok': true};
    final service = CartService(api: api);

    await service.addToCart('p1', 2);

    expect(api.lastPath, '/cart');
    expect(api.lastBody, {'product_id': 'p1', 'quantity': 2});
  });

  test(
    'CartProvider fetchCart calculates total items and grand total',
    () async {
      final provider = CartProvider(
        cartService: FakeCartService(
          items: const [CartItemModel(id: 'c1', product: product, quantity: 2)],
        ),
      );

      await provider.fetchCart();

      expect(provider.totalItems, 2);
      expect(provider.grandTotal, 24000000);
      expect(provider.isLoading, isFalse);
    },
  );

  test('CartProvider rolls back quantity when update fails', () async {
    final service = FakeCartService(
      failUpdate: true,
      items: const [CartItemModel(id: 'c1', product: product, quantity: 2)],
    );
    final provider = CartProvider(cartService: service);
    await provider.fetchCart();

    await provider.updateQuantity('c1', 3);

    expect(provider.cartItems.single.quantity, 2);
    expect(provider.errorMessage, 'Gagal mengubah quantity.');
  });

  testWidgets('CartPage renders empty cart state', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartProvider(cartService: FakeCartService()),
        child: const MaterialApp(home: CartPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keranjang kosong'), findsOneWidget);
  });
}
