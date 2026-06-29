// Purpose: Tests for wishlist local storage and provider state.
// Main callers: flutter test.
// Key dependencies: flutter_test, Hive, WishlistService, WishlistProvider, ProductModel.
// Main/public functions: wishlist module behavior tests.
// Side effects: Creates a temporary Hive directory during tests.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/services/wishlist_service.dart';
import 'package:flutter_toko/models/product_model.dart';
import 'package:flutter_toko/providers/wishlist_provider.dart';
import 'package:hive/hive.dart';

class FakeWishlistService extends WishlistService {
  FakeWishlistService({List<ProductModel> products = const []})
    : products = List<ProductModel>.of(products);

  List<ProductModel> products;

  @override
  Future<List<ProductModel>> loadWishlist() async => products;

  @override
  Future<void> saveProduct(ProductModel product) async {
    products = [...products.where((item) => item.id != product.id), product];
  }

  @override
  Future<void> removeProduct(String productId) async {
    products = products.where((item) => item.id != productId).toList();
  }

  @override
  Future<bool> contains(String productId) async {
    return products.any((item) => item.id == productId);
  }
}

void main() {
  const product = ProductModel(
    id: 'p1',
    name: 'Laptop',
    price: 12000000,
    description: 'Laptop kerja',
    imageUrl: '',
    categoryId: 'c1',
    categoryName: 'Elektronik',
    stock: 5,
    isActive: true,
    rating: 4.5,
    reviewCount: 2,
  );

  group('WishlistService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('wishlist_test_');
      Hive.init(tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'saveProduct stores ProductModel json and contains finds it',
      () async {
        final service = WishlistService();

        await service.saveProduct(product);

        expect(await service.contains('p1'), isTrue);
        final products = await service.loadWishlist();
        expect(products.single.name, 'Laptop');
      },
    );

    test('removeProduct deletes product from wishlist box', () async {
      final service = WishlistService();
      await service.saveProduct(product);

      await service.removeProduct('p1');

      expect(await service.contains('p1'), isFalse);
      expect(await service.loadWishlist(), isEmpty);
    });
  });

  test('WishlistProvider toggles product in and out', () async {
    final provider = WishlistProvider(wishlistService: FakeWishlistService());

    await provider.toggleWishlist(product);
    expect(provider.isWishlisted('p1'), isTrue);
    expect(provider.wishlistProducts.single.id, 'p1');

    await provider.toggleWishlist(product);
    expect(provider.isWishlisted('p1'), isFalse);
    expect(provider.wishlistProducts, isEmpty);
  });
}
