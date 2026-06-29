// Purpose: Widget tests for redesigned admin mobile UI.
// Main callers: flutter test.
// Key dependencies: flutter_test, Provider, AdminHomePage, AdminProvider, AdminService fakes.
// Main/public functions: Admin redesign widget behavior tests.
// Side effects: Pumps widgets with fake admin service data only.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/services/admin_service.dart';
import 'package:flutter_toko/core/theme/app_spacing.dart';
import 'package:flutter_toko/features/admin/admin_home_page.dart';
import 'package:flutter_toko/features/admin/widgets/admin_components.dart';
import 'package:flutter_toko/models/category_model.dart';
import 'package:flutter_toko/models/order_model.dart';
import 'package:flutter_toko/models/product_model.dart';
import 'package:flutter_toko/providers/admin_provider.dart';
import 'package:provider/provider.dart';

class FakeAdminUiService extends AdminService {
  num? updatedProductPrice;

  @override
  Future<Map<String, dynamic>> fetchStats() async => {
    'total_products': 12,
    'total_orders': 5,
    'total_users': 3,
    'total_revenue': 1250000,
  };

  @override
  Future<List<Map<String, dynamic>>> fetchLowStock({int threshold = 10}) async {
    return [
      {'name': 'Keyboard', 'stock': 2},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTopProducts({int limit = 5}) async {
    return [
      {'name': 'Laptop', 'total_sold': 8},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecentOrders({int limit = 5}) async {
    return [
      {'id': 'ord-12345678', 'status': 'pending'},
    ];
  }

  @override
  Future<List<OrderModel>> fetchOrders({
    String status = '',
    int page = 1,
  }) async {
    return [
      OrderModel.fromJson({
        'id': 'ord-12345678',
        'status': 'pending',
        'total': 300000,
        'shipping_address': 'Jl. Admin No. 1',
      }),
    ];
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    return const [CategoryModel(id: 'c1', name: 'Elektronik')];
  }

  @override
  Future<List<ProductModel>> fetchProducts({int page = 1}) async {
    return [
      ProductModel.fromJson({
        'id': 'p1',
        'name': 'Laptop',
        'description': 'Laptop gaming premium',
        'image_url': 'https://example.com/laptop.jpg',
        'price': 15000000,
        'stock': 4,
        'category_id': 'c1',
        'category_name': 'Elektronik',
        'is_active': true,
      }),
      ProductModel.fromJson({
        'id': 'p2',
        'name': 'Mouse',
        'price': 250000,
        'stock': 12,
        'category_id': 'c1',
        'category_name': 'Elektronik',
        'is_active': true,
      }),
    ];
  }

  @override
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
    updatedProductPrice = price;
    return ProductModel.fromJson({
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'category_name': 'Elektronik',
      'is_active': isActive,
    });
  }
}

void main() {
  testWidgets('AdminHomePage uses redesigned dashboard and sheet forms', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminProvider(adminService: FakeAdminUiService()),
        child: const MaterialApp(home: AdminHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ringkasan Toko'), findsOneWidget);
    expect(find.text('Kelola Produk'), findsNothing);

    await tester.tap(find.text('Produk').last);
    await tester.pumpAndSettle();

    expect(find.text('Kelola Produk'), findsOneWidget);
    expect(find.text('Nama Produk'), findsNothing);

    await tester.tap(find.text('Tambah Produk'));
    await tester.pumpAndSettle();

    expect(find.text('Nama Produk'), findsOneWidget);
  });

  testWidgets(
    'AdminHomePage uses custom token surfaces instead of template cards',
    (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AdminProvider(adminService: FakeAdminUiService()),
          child: const MaterialApp(home: AdminHomePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsNothing);
      expect(find.byType(ListTile), findsNothing);

      for (final label in ['Pesanan', 'Kategori', 'Produk']) {
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
        expect(find.byType(Card), findsNothing);
        expect(find.byType(ListTile), findsNothing);
      }
    },
  );

  testWidgets('AdminProductTab keeps visible spacing between product rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminProvider(adminService: FakeAdminUiService()),
        child: const MaterialApp(home: AdminHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Produk').last);
    await tester.pumpAndSettle();

    final laptopSurface = find
        .ancestor(of: find.text('Laptop'), matching: find.byType(AdminSurface))
        .first;
    final mouseSurface = find
        .ancestor(of: find.text('Mouse'), matching: find.byType(AdminSurface))
        .first;
    final gap =
        tester.getTopLeft(mouseSurface).dy -
        tester.getBottomLeft(laptopSurface).dy;

    expect(gap, greaterThanOrEqualTo(AppSpacing.md));
  });

  testWidgets('AdminProductTab opens detail sheet before editing a product', (
    tester,
  ) async {
    final service = FakeAdminUiService();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdminProvider(adminService: service),
        child: const MaterialApp(home: AdminHomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Produk').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Laptop'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Produk'), findsOneWidget);
    expect(find.text('Laptop gaming premium'), findsOneWidget);
    expect(find.text('https://example.com/laptop.jpg'), findsOneWidget);
    expect(find.text('Edit Produk'), findsOneWidget);

    await tester.ensureVisible(find.text('Edit Produk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Produk'));
    await tester.pumpAndSettle();

    expect(find.text('Detail Produk'), findsNothing);
    expect(find.text('Nama Produk'), findsOneWidget);

    final priceFieldFinder = find
        .ancestor(of: find.text('Harga'), matching: find.byType(TextFormField))
        .first;
    final priceField = tester.widget<TextFormField>(priceFieldFinder);
    expect(priceField.controller?.text, 'Rp 15.000.000');

    await tester.enterText(priceFieldFinder, 'Rp 16.000.000');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(service.updatedProductPrice, 16000000);
  });
}
