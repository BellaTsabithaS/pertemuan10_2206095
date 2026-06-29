# Flutter E-Commerce UAS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Flutter app as a modular e-commerce UAS app that consumes the provided REST API and follows `DESIGN.md` through reusable theme tokens.

**Architecture:** Treat the current app as disposable. Build a modular minimal Flutter app where pages call providers, providers call services, and services call `ApiService` or local storage services. Keep design consistency by routing all colors, typography, spacing, radius, and shared widgets through `core/theme` and `core/widgets`.

**Tech Stack:** Flutter, Dart, Provider, http, SharedPreferences, Hive, Hive Flutter, intl, cached_network_image, flutter_rating_bar, shimmer, flutter_local_notifications.

---

## File Map

Create these files:

```txt
lib/app.dart
lib/core/constants/api_constants.dart
lib/core/constants/app_constants.dart
lib/core/exceptions/app_exception.dart
lib/core/helpers/currency_helper.dart
lib/core/helpers/date_helper.dart
lib/core/helpers/snackbar_helper.dart
lib/core/services/api_service.dart
lib/core/services/auth_service.dart
lib/core/services/cart_service.dart
lib/core/services/notification_service.dart
lib/core/services/order_service.dart
lib/core/services/product_service.dart
lib/core/services/review_service.dart
lib/core/services/storage_service.dart
lib/core/services/wishlist_service.dart
lib/core/theme/app_colors.dart
lib/core/theme/app_radius.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_theme.dart
lib/core/widgets/empty_state_widget.dart
lib/core/widgets/error_state_widget.dart
lib/core/widgets/loading_widget.dart
lib/core/widgets/product_card.dart
lib/features/auth/login_page.dart
lib/features/auth/register_page.dart
lib/features/cart/cart_page.dart
lib/features/checkout/checkout_page.dart
lib/features/checkout/order_success_page.dart
lib/features/home/home_page.dart
lib/features/order/order_detail_page.dart
lib/features/order/order_history_page.dart
lib/features/product/product_detail_page.dart
lib/features/profile/profile_page.dart
lib/features/splash/splash_page.dart
lib/features/wishlist/wishlist_page.dart
lib/models/cart_item_model.dart
lib/models/category_model.dart
lib/models/order_model.dart
lib/models/product_model.dart
lib/models/review_model.dart
lib/models/user_model.dart
lib/providers/auth_provider.dart
lib/providers/cart_provider.dart
lib/providers/order_provider.dart
lib/providers/product_provider.dart
lib/providers/theme_provider.dart
lib/providers/wishlist_provider.dart
test/currency_helper_test.dart
test/order_model_test.dart
test/product_model_test.dart
```

Modify these files:

```txt
lib/main.dart
pubspec.yaml
README.md
```

Do not preserve old single-file product CRUD behavior.

## Task 1: Dependencies And Cleanup

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Create: `lib/app.dart`

- [ ] **Step 1: Add dependencies**

Edit `pubspec.yaml` dependencies to include:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cached_network_image: ^3.3.1
  flutter_local_notifications: ^17.2.4
  flutter_rating_bar: ^4.0.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.2.2
  intl: ^0.19.0
  provider: ^6.1.2
  shared_preferences: ^2.3.3
  shimmer: ^3.0.0
```

Run:

```bash
flutter pub get
```

Expected: command exits 0 and updates `pubspec.lock`.

- [ ] **Step 2: Replace `lib/main.dart` with bootstrap only**

Use:

```dart
// Purpose: Flutter app bootstrap for the e-commerce UAS app.
// Main callers: Flutter runtime via main().
// Key dependencies: Hive Flutter, NotificationService, App.
// Main/public functions: main.
// Side effects: Initializes Hive storage and local notification plumbing before runApp().

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService.instance.initialize();
  runApp(const App());
}
```

- [ ] **Step 3: Create temporary `lib/app.dart`**

Use a compile-safe shell that later tasks replace with full providers:

```dart
// Purpose: Root Flutter app widget during initial rebuild.
// Main callers: main().
// Key dependencies: MaterialApp.
// Main/public functions: App.
// Side effects: None.

import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('Flutter E-Commerce UAS')),
      ),
    );
  }
}
```

- [ ] **Step 4: Run analyzer**

Run:

```bash
flutter analyze
```

Expected: no errors. Existing warnings from generated platform files are not acceptable; fix only warnings in files touched by this plan.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/main.dart lib/app.dart
git commit -m "chore: reset Flutter app bootstrap"
```

## Task 2: Theme Tokens From DESIGN.md

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_spacing.dart`
- Create: `lib/core/theme/app_radius.dart`
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `lib/core/theme/app_theme.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Add color tokens**

Create `app_colors.dart`:

```dart
// Purpose: Color tokens mapped from DESIGN.md for the e-commerce app.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter Color.
// Main/public functions: AppColors.
// Side effects: None.

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF0066CC);
  static const primaryFocus = Color(0xFF0071E3);
  static const primaryOnDark = Color(0xFF2997FF);
  static const ink = Color(0xFF1D1D1F);
  static const body = Color(0xFF1D1D1F);
  static const bodyOnDark = Color(0xFFFFFFFF);
  static const bodyMuted = Color(0xFFCCCCCC);
  static const inkMuted80 = Color(0xFF333333);
  static const inkMuted48 = Color(0xFF7A7A7A);
  static const dividerSoft = Color(0xFFF0F0F0);
  static const hairline = Color(0xFFE0E0E0);
  static const canvas = Color(0xFFFFFFFF);
  static const canvasParchment = Color(0xFFF5F5F7);
  static const surfacePearl = Color(0xFFFAFAFC);
  static const surfaceTile1 = Color(0xFF272729);
  static const surfaceTile2 = Color(0xFF2A2A2C);
  static const surfaceTile3 = Color(0xFF252527);
  static const surfaceBlack = Color(0xFF000000);
  static const surfaceChipTranslucent = Color(0xA3D2D2D7);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onDark = Color(0xFFFFFFFF);

  static const statusPending = Color(0xFFB7791F);
  static const statusProcessing = Color(0xFF0066CC);
  static const statusShipped = Color(0xFF6B46C1);
  static const statusDelivered = Color(0xFF2F855A);
  static const statusCancelled = Color(0xFFC53030);
}
```

- [ ] **Step 2: Add spacing and radius tokens**

Create `app_spacing.dart`:

```dart
// Purpose: Spacing tokens mapped from DESIGN.md.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: None.
// Main/public functions: AppSpacing.
// Side effects: None.

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 17;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double section = 80;
}
```

Create `app_radius.dart`:

```dart
// Purpose: Radius tokens mapped from DESIGN.md.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter BorderRadius.
// Main/public functions: AppRadius.
// Side effects: None.

import 'package:flutter/material.dart';

class AppRadius {
  const AppRadius._();

  static const double none = 0;
  static const double xs = 5;
  static const double sm = 8;
  static const double md = 11;
  static const double lg = 18;
  static const double pill = 9999;

  static BorderRadius circular(double value) => BorderRadius.circular(value);
}
```

- [ ] **Step 3: Add text styles**

Create `app_text_styles.dart` with body and display styles used across the app:

```dart
// Purpose: Typography tokens mapped from DESIGN.md.
// Main callers: AppTheme, shared widgets, feature pages.
// Key dependencies: Flutter TextStyle.
// Main/public functions: AppTextStyles.
// Side effects: None.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const fontFamily = 'Roboto';

  static const heroDisplay = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.w600,
    height: 1.07,
    letterSpacing: -0.28,
    color: AppColors.ink,
  );

  static const displayLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.10,
    color: AppColors.ink,
  );

  static const tagline = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    height: 1.19,
    letterSpacing: 0.231,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.47,
    letterSpacing: -0.374,
    color: AppColors.body,
  );

  static const bodyStrong = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.24,
    letterSpacing: -0.374,
    color: AppColors.body,
  );

  static const caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: -0.224,
    color: AppColors.inkMuted80,
  );

  static const captionStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: -0.224,
    color: AppColors.ink,
  );

  static const finePrint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1,
    letterSpacing: -0.12,
    color: AppColors.inkMuted48,
  );
}
```

- [ ] **Step 4: Add app theme**

Create `app_theme.dart`:

```dart
// Purpose: Light and dark ThemeData built from DESIGN.md tokens.
// Main callers: App.
// Key dependencies: AppColors, AppRadius, AppTextStyles.
// Main/public functions: AppTheme.light, AppTheme.dark.
// Side effects: None.

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _base(
        brightness: Brightness.light,
        scaffoldBackground: AppColors.canvasParchment,
        surface: AppColors.canvas,
        textColor: AppColors.ink,
      );

  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        scaffoldBackground: AppColors.surfaceTile1,
        surface: AppColors.surfaceTile2,
        textColor: AppColors.bodyOnDark,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color surface,
    required Color textColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.displayLarge,
        titleMedium: AppTextStyles.tagline,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.caption,
        labelLarge: AppTextStyles.captionStrong,
      ).apply(bodyColor: textColor, displayColor: textColor),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: AppColors.primaryFocus, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.hairline),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Wire theme into `App`**

Replace `lib/app.dart` with:

```dart
// Purpose: Root app widget and global theme wiring.
// Main callers: main().
// Key dependencies: MaterialApp, AppTheme.
// Main/public functions: App.
// Side effects: None.

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter E-Commerce UAS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const Scaffold(
        body: Center(child: Text('Flutter E-Commerce UAS')),
      ),
    );
  }
}
```

- [ ] **Step 6: Run analyzer and commit**

Run:

```bash
flutter analyze
```

Expected: no errors.

Commit:

```bash
git add lib/app.dart lib/core/theme
git commit -m "feat: add design token theme"
```

## Task 3: Core Models, Helpers, And Tests

**Files:**
- Create: `lib/models/product_model.dart`
- Create: `lib/models/order_model.dart`
- Create: `lib/models/category_model.dart`
- Create: `lib/models/review_model.dart`
- Create: `lib/models/user_model.dart`
- Create: `lib/models/cart_item_model.dart`
- Create: `lib/core/helpers/currency_helper.dart`
- Create: `lib/core/helpers/date_helper.dart`
- Test: `test/currency_helper_test.dart`
- Test: `test/product_model_test.dart`
- Test: `test/order_model_test.dart`

- [ ] **Step 1: Write helper tests**

Create `test/currency_helper_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/helpers/currency_helper.dart';

void main() {
  test('formatRupiah formats whole numbers for Indonesian currency', () {
    expect(formatRupiah(12000), 'Rp 12.000');
  });
}
```

Create `test/product_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/models/product_model.dart';

void main() {
  test('ProductModel parses missing optional fields safely', () {
    final product = ProductModel.fromJson({
      'id': 'p1',
      'name': 'Laptop',
      'price': 12000000,
    });

    expect(product.id, 'p1');
    expect(product.name, 'Laptop');
    expect(product.price, 12000000);
    expect(product.imageUrl, '');
    expect(product.stock, 0);
  });
}
```

Create `test/order_model_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/models/order_model.dart';

void main() {
  test('OrderModel uses first eight UUID characters as display number', () {
    final order = OrderModel.fromJson({
      'id': '12345678-abcd-efgh',
      'status': 'pending',
      'total': 20000,
      'created_at': '2026-06-28T00:00:00.000Z',
      'items': [],
    });

    expect(order.displayNumber, '12345678');
  });
}
```

- [ ] **Step 2: Run tests and verify failure**

Run:

```bash
flutter test test/currency_helper_test.dart test/product_model_test.dart test/order_model_test.dart
```

Expected: FAIL because helper and model files do not exist.

- [ ] **Step 3: Add helpers**

Create `currency_helper.dart`:

```dart
// Purpose: Currency formatting helpers for product, cart, and order prices.
// Main callers: ProductCard, ProductDetailPage, CartPage, CheckoutPage, Order pages.
// Key dependencies: intl NumberFormat.
// Main/public functions: formatRupiah.
// Side effects: None.

import 'package:intl/intl.dart';

String formatRupiah(num value) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(value);
}
```

Create `date_helper.dart`:

```dart
// Purpose: Date formatting helpers for order history and detail.
// Main callers: OrderHistoryPage, OrderDetailPage.
// Key dependencies: intl DateFormat.
// Main/public functions: formatDate.
// Side effects: None.

import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
}
```

- [ ] **Step 4: Add minimal model implementations**

Create `product_model.dart`:

```dart
// Purpose: Product, category, and review-facing product data model.
// Main callers: ProductProvider, CartProvider, WishlistProvider, ProductCard.
// Key dependencies: None.
// Main/public functions: ProductModel, ProductModel.fromJson, toJson.
// Side effects: None.

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.rating,
    required this.reviewCount,
  });

  final String id;
  final String name;
  final num price;
  final String description;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final int stock;
  final num rating;
  final int reviewCount;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return ProductModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      price: json['price'] is num ? json['price'] as num : num.tryParse('${json['price'] ?? 0}') ?? 0,
      description: '${json['description'] ?? ''}',
      imageUrl: '${json['image_url'] ?? json['imageUrl'] ?? json['image'] ?? ''}',
      categoryId: category is Map ? '${category['id'] ?? json['category_id'] ?? ''}' : '${json['category_id'] ?? ''}',
      categoryName: category is Map ? '${category['name'] ?? ''}' : '${json['category_name'] ?? ''}',
      stock: json['stock'] is int ? json['stock'] as int : int.tryParse('${json['stock'] ?? 0}') ?? 0,
      rating: json['rating'] is num ? json['rating'] as num : num.tryParse('${json['rating'] ?? 0}') ?? 0,
      reviewCount: json['review_count'] is int ? json['review_count'] as int : int.tryParse('${json['review_count'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'stock': stock,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}
```

Create other model files with the same defensive parser pattern:

```dart
// Purpose: Order data model for checkout, history, and detail screens.
// Main callers: OrderProvider, OrderHistoryPage, OrderDetailPage.
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
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().map(CartItemModel.fromJson).toList()
        : <CartItemModel>[];
    final parsedTotal = json['total'] is num ? json['total'] as num : num.tryParse('${json['total'] ?? ''}');
    final calculatedTotal = items.fold<num>(0, (sum, item) => sum + item.subtotal);
    return OrderModel(
      id: '${json['id'] ?? ''}',
      status: '${json['status'] ?? 'pending'}',
      total: parsedTotal ?? calculatedTotal,
      createdAt: DateTime.tryParse('${json['created_at'] ?? json['createdAt'] ?? ''}'),
      address: '${json['address'] ?? json['shipping_address'] ?? ''}',
      note: '${json['note'] ?? ''}',
      items: items,
    );
  }
}
```

- [ ] **Step 5: Run tests and analyzer**

Run:

```bash
flutter test test/currency_helper_test.dart test/product_model_test.dart test/order_model_test.dart
flutter analyze
```

Expected: tests pass and analyzer has no errors. If `CartItemModel` is missing during Step 4, create it in the same step before rerunning:

```dart
// Purpose: Cart item model for cart and order item rows.
// Main callers: CartProvider, OrderModel, CartPage, OrderDetailPage.
// Key dependencies: ProductModel.
// Main/public functions: CartItemModel, CartItemModel.fromJson, subtotal.
// Side effects: None.

import 'product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  final String id;
  final ProductModel product;
  final int quantity;

  num get subtotal => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: '${json['id'] ?? ''}',
      product: ProductModel.fromJson(
        json['product'] is Map<String, dynamic> ? json['product'] as Map<String, dynamic> : json,
      ),
      quantity: json['quantity'] is int ? json['quantity'] as int : int.tryParse('${json['quantity'] ?? 1}') ?? 1,
    );
  }
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/models lib/core/helpers test
git commit -m "feat: add core models and helper tests"
```

## Task 4: API, Storage, And Shared Widgets

**Files:**
- Create: `lib/core/constants/api_constants.dart`
- Create: `lib/core/constants/app_constants.dart`
- Create: `lib/core/exceptions/app_exception.dart`
- Create: `lib/core/services/api_service.dart`
- Create: `lib/core/services/storage_service.dart`
- Create: `lib/core/helpers/snackbar_helper.dart`
- Create: `lib/core/widgets/loading_widget.dart`
- Create: `lib/core/widgets/error_state_widget.dart`
- Create: `lib/core/widgets/empty_state_widget.dart`

- [ ] **Step 1: Add constants and exception**

Create constants:

```dart
// Purpose: API endpoint constants for REST services.
// Main callers: ApiService and feature services.
// Key dependencies: None.
// Main/public functions: ApiConstants.
// Side effects: None.

class ApiConstants {
  const ApiConstants._();

  static const baseUrl = 'https://api-tb-f2wk.onrender.com/api';
  static const connectTimeout = Duration(seconds: 20);
}
```

Create exception:

```dart
// Purpose: Normalized app exception for API and local-service failures.
// Main callers: ApiService, providers.
// Key dependencies: None.
// Main/public functions: AppException.
// Side effects: None.

class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.isUnauthorized = false});

  final String message;
  final int? statusCode;
  final bool isUnauthorized;

  @override
  String toString() => message;
}
```

- [ ] **Step 2: Add ApiService**

Create `api_service.dart`:

```dart
// Purpose: Shared HTTP wrapper for the app REST API.
// Main callers: AuthService, ProductService, CartService, OrderService, ReviewService.
// Key dependencies: http, StorageService, ApiConstants, AppException.
// Main/public functions: get, post, put, delete.
// Side effects: Performs HTTP requests and reads stored auth token.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../exceptions/app_exception.dart';
import 'storage_service.dart';

class ApiService {
  ApiService({http.Client? client, StorageService? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? StorageService.instance;

  final http.Client _client;
  final StorageService _storage;

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) => _send('POST', path, body: body);
  Future<dynamic> put(String path, {Map<String, dynamic>? body}) => _send('PUT', path, body: body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, {Map<String, dynamic>? body}) async {
    try {
      final token = await _storage.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final uri = Uri.parse('${ApiConstants.baseUrl}$path');
      final response = await switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(uri, headers: headers, body: jsonEncode(body ?? {})),
        'PUT' => _client.put(uri, headers: headers, body: jsonEncode(body ?? {})),
        'DELETE' => _client.delete(uri, headers: headers),
        _ => throw const AppException('Metode request tidak valid.'),
      }.timeout(ApiConstants.connectTimeout);
      return _handleResponse(response);
    } on SocketException {
      throw const AppException('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw const AppException('Koneksi lambat. Coba lagi.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final data = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    final message = data is Map<String, dynamic>
        ? '${data['message'] ?? data['error'] ?? 'Request gagal.'}'
        : 'Request gagal.';
    throw AppException(
      message,
      statusCode: response.statusCode,
      isUnauthorized: response.statusCode == 401,
    );
  }
}
```

- [ ] **Step 3: Add StorageService**

Create `storage_service.dart`:

```dart
// Purpose: SharedPreferences wrapper for token and theme persistence.
// Main callers: ApiService, AuthProvider, ThemeProvider.
// Key dependencies: shared_preferences.
// Main/public functions: getToken, saveToken, clearToken, getDarkMode, saveDarkMode.
// Side effects: Reads and writes SharedPreferences.

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();
  static final instance = StorageService._();

  static const _tokenKey = 'access_token';
  static const _darkModeKey = 'is_dark_mode';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }
}
```

- [ ] **Step 4: Add shared widgets and snackbar helper**

Create simple reusable widgets with text, icon, and optional retry action. Use `AppColors.primary`, `AppSpacing`, and `AppTextStyles.body`.

- [ ] **Step 5: Run analyzer and commit**

```bash
flutter analyze
git add lib/core
git commit -m "feat: add core API and shared UI utilities"
```

Expected: analyzer has no errors.

## Task 5: Auth, Profile, Theme Provider, And App Shell

**Files:**
- Create: `lib/core/services/auth_service.dart`
- Create: `lib/providers/auth_provider.dart`
- Create: `lib/providers/theme_provider.dart`
- Create: `lib/features/splash/splash_page.dart`
- Create: `lib/features/auth/login_page.dart`
- Create: `lib/features/auth/register_page.dart`
- Create: `lib/features/profile/profile_page.dart`
- Modify: `lib/app.dart`
- Create/complete: `lib/models/user_model.dart`

- [ ] **Step 1: Add UserModel and AuthService**

Implement `UserModel.fromJson` with `id`, `name`, `email`, `phone`. Implement `AuthService` methods:

```dart
Future<void> register(String name, String email, String password)
Future<String> login(String email, String password)
Future<UserModel> getProfile()
Future<UserModel> updateProfile(String name, String phone)
```

Use these endpoints:

```txt
POST /auth/register
POST /auth/login
GET /auth/profile
PUT /auth/profile
```

- [ ] **Step 2: Add providers**

`AuthProvider` owns user, token, loading, and errors. `ThemeProvider` owns dark mode and persists it through `StorageService`.

Provider unauthorized rule:

```dart
if (error.isUnauthorized) {
  await logout();
}
```

- [ ] **Step 3: Replace `App` with MultiProvider**

Wire `AuthProvider`, `ThemeProvider`, and `SplashPage`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
    ChangeNotifierProvider(create: (_) => AuthProvider()..checkLoginStatus()),
  ],
  child: Consumer<ThemeProvider>(
    builder: (context, themeProvider, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter E-Commerce UAS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashPage(),
    ),
  ),
)
```

- [ ] **Step 4: Add pages**

Create pages:

```txt
SplashPage: routes to LoginPage or HomePage based on AuthProvider.
LoginPage: email/password form, login button, register link.
RegisterPage: name/email/password form, register button, login link.
ProfilePage: profile form, dark mode switch, logout button.
```

Validation:

```txt
Email contains @ and .
Password length >= 6
Name not empty
Phone optional, digits only when filled
```

- [ ] **Step 5: Run checks and commit**

```bash
flutter analyze
flutter test
git add lib/app.dart lib/features/splash lib/features/auth lib/features/profile lib/providers/auth_provider.dart lib/providers/theme_provider.dart lib/core/services/auth_service.dart lib/models/user_model.dart
git commit -m "feat: add auth profile and theme flow"
```

Expected: analyzer and tests pass.

## Task 6: Product Catalog, Detail, Reviews, And Product Card

**Files:**
- Create: `lib/core/services/product_service.dart`
- Create: `lib/core/services/review_service.dart`
- Create: `lib/providers/product_provider.dart`
- Create: `lib/core/widgets/product_card.dart`
- Create: `lib/features/home/home_page.dart`
- Create: `lib/features/product/product_detail_page.dart`
- Complete: `lib/models/category_model.dart`
- Complete: `lib/models/review_model.dart`
- Modify: `lib/features/splash/splash_page.dart`

- [ ] **Step 1: Add category and review models**

Create defensive parsers for:

```txt
CategoryModel: id, name
ReviewModel: id, userName, rating, comment, createdAt
```

- [ ] **Step 2: Add services**

Implement:

```dart
ProductService.fetchProducts({String search = '', String category = '', String sort = '', int page = 1})
ProductService.fetchCategories()
ProductService.fetchProductDetail(String id)
ReviewService.fetchProductReviews(String productId)
ReviewService.addReview(String productId, int rating, String comment)
```

- [ ] **Step 3: Add ProductProvider**

State and methods must match the spec:

```txt
products, categories, selectedProduct, reviews, isLoading, isLoadingMore, searchQuery, selectedCategory, selectedSort, currentPage, hasMore, errorMessage
fetchProducts, loadMoreProducts, searchProducts, filterByCategory, sortProducts, fetchProductDetail, fetchCategories, fetchProductReviews, addReview
```

- [ ] **Step 4: Add ProductCard**

ProductCard props:

```dart
const ProductCard({
  super.key,
  required this.product,
  required this.onTap,
  required this.onWishlistTap,
  required this.isWishlisted,
});
```

Use `CachedNetworkImage`, `formatRupiah`, utility-card styling, and a circular wishlist icon button.

- [ ] **Step 5: Add HomePage and ProductDetailPage**

HomePage:

```txt
Search input
Category filter
Sort dropdown
Product grid
Infinite scroll
Bottom navigation shell
Cart badge reads CartProvider.totalItems after Task 7 wires CartProvider
```

ProductDetailPage:

```txt
Large image
Name, price, stock, category
Average rating and review count
Review list
Review form using flutter_rating_bar
Add to cart CTA
Wishlist toggle
```

- [ ] **Step 6: Run checks and commit**

```bash
flutter analyze
flutter test
git add lib/core/services/product_service.dart lib/core/services/review_service.dart lib/providers/product_provider.dart lib/core/widgets/product_card.dart lib/features/home lib/features/product lib/models/category_model.dart lib/models/review_model.dart lib/features/splash/splash_page.dart
git commit -m "feat: add product catalog and detail"
```

Expected: analyzer and tests pass.

## Task 7: Cart

**Files:**
- Create: `lib/core/services/cart_service.dart`
- Create: `lib/providers/cart_provider.dart`
- Create: `lib/features/cart/cart_page.dart`
- Complete: `lib/models/cart_item_model.dart`
- Modify: `lib/app.dart`
- Modify: `lib/features/home/home_page.dart`
- Modify: `lib/features/product/product_detail_page.dart`

- [ ] **Step 1: Add CartService**

Implement:

```dart
Future<List<CartItemModel>> fetchCart()
Future<void> addToCart(String productId, int quantity)
Future<CartItemModel> updateQuantity(String cartItemId, int quantity)
Future<void> removeItem(String cartItemId)
Future<void> clearCart()
```

Endpoints:

```txt
GET /cart
POST /cart
PUT /cart/:id
DELETE /cart/:id
DELETE /cart
```

- [ ] **Step 2: Add CartProvider**

Provider state:

```txt
cartItems, isLoading, isUpdating, errorMessage, totalItems, grandTotal
```

Implement rollback for failed quantity update:

```txt
Save old quantity.
Apply optimistic quantity.
Call API.
If API fails, restore old quantity and set errorMessage.
```

- [ ] **Step 3: Add CartPage**

Cart UI:

```txt
Utility cards for items
Product image
Product name
Unit price
Plus/minus buttons
Remove button
Clear cart button with confirmation
Sticky grand total bar
Checkout blue pill CTA
Empty state
```

- [ ] **Step 4: Wire cart provider and navigation**

Add `CartProvider` to `MultiProvider`. Connect product detail add-to-cart button. Connect Home bottom nav cart tab and badge.

- [ ] **Step 5: Run checks and commit**

```bash
flutter analyze
flutter test
git add lib/core/services/cart_service.dart lib/providers/cart_provider.dart lib/features/cart lib/models/cart_item_model.dart lib/app.dart lib/features/home lib/features/product
git commit -m "feat: add cart flow"
```

Expected: analyzer and tests pass.

## Task 8: Checkout, Orders, And Notifications

**Files:**
- Create: `lib/core/services/order_service.dart`
- Create: `lib/core/services/notification_service.dart`
- Create: `lib/providers/order_provider.dart`
- Create: `lib/features/checkout/checkout_page.dart`
- Create: `lib/features/checkout/order_success_page.dart`
- Create: `lib/features/order/order_history_page.dart`
- Create: `lib/features/order/order_detail_page.dart`
- Complete: `lib/models/order_model.dart`
- Modify: `lib/app.dart`
- Modify: `lib/features/cart/cart_page.dart`
- Modify: `lib/features/home/home_page.dart`

- [ ] **Step 1: Add NotificationService**

Create singleton with:

```dart
Future<void> initialize()
Future<void> showOrderSuccess()
```

Use channel:

```txt
id: orders
name: Orders
description: Order status notifications
```

Notification copy:

```txt
Pesanan Berhasil
Pesanan kamu berhasil dibuat. Cek riwayat pesanan untuk melihat detailnya.
```

- [ ] **Step 2: Add OrderService and OrderProvider**

Implement:

```dart
OrderService.checkout(String address, String note)
OrderService.fetchOrders({int page = 1})
OrderService.fetchOrderDetail(String id)
OrderProvider.checkout(address, note)
OrderProvider.fetchOrders()
OrderProvider.loadMoreOrders()
OrderProvider.fetchOrderDetail(id)
```

- [ ] **Step 3: Add checkout and order pages**

Checkout:

```txt
Cart summary
Address field required min 10 chars
Note field optional
Confirmation dialog before submit
Submit disabled while loading
```

Order success:

```txt
Headline
Short message
CTA to OrderHistoryPage
```

Order history:

```txt
List orders
Display number first 8 UUID chars
Date
Total
Status chip
Pagination load more
```

Order detail:

```txt
Status
Address
Note
Date
Items
Subtotal
Total
```

- [ ] **Step 4: Wire notification after checkout success**

Only call:

```dart
await NotificationService.instance.showOrderSuccess();
```

after `POST /orders` succeeds. Do not block order success UI when notification permission is denied.

- [ ] **Step 5: Run checks and commit**

```bash
flutter analyze
flutter test
git add lib/core/services/order_service.dart lib/core/services/notification_service.dart lib/providers/order_provider.dart lib/features/checkout lib/features/order lib/models/order_model.dart lib/app.dart lib/features/cart lib/features/home
git commit -m "feat: add checkout orders and notifications"
```

Expected: analyzer and tests pass.

## Task 9: Wishlist And Dark Mode Completion

**Files:**
- Create: `lib/core/services/wishlist_service.dart`
- Create: `lib/providers/wishlist_provider.dart`
- Create: `lib/features/wishlist/wishlist_page.dart`
- Modify: `lib/app.dart`
- Modify: `lib/features/home/home_page.dart`
- Modify: `lib/features/product/product_detail_page.dart`
- Modify: `lib/features/profile/profile_page.dart`

- [ ] **Step 1: Add WishlistService**

Use Hive box name:

```txt
wishlist_products
```

Methods:

```dart
Future<List<ProductModel>> loadWishlist()
Future<void> saveProduct(ProductModel product)
Future<void> removeProduct(String productId)
Future<bool> contains(String productId)
```

Store `ProductModel.toJson()` only.

- [ ] **Step 2: Add WishlistProvider**

State:

```txt
wishlistProducts, isLoading, errorMessage
```

Methods:

```txt
loadWishlist, addWishlist, removeWishlist, toggleWishlist, isWishlisted
```

- [ ] **Step 3: Add WishlistPage**

UI:

```txt
Grid using ProductCard
Empty state with CTA to Home
Delete from wishlist through heart icon
```

- [ ] **Step 4: Wire wishlist and dark mode**

Add `WishlistProvider` to `MultiProvider`. Connect product card and product detail wishlist toggles. Ensure `ProfilePage` dark mode switch calls `ThemeProvider.toggleTheme()`.

- [ ] **Step 5: Run checks and commit**

```bash
flutter analyze
flutter test
git add lib/core/services/wishlist_service.dart lib/providers/wishlist_provider.dart lib/features/wishlist lib/app.dart lib/features/home lib/features/product lib/features/profile
git commit -m "feat: add wishlist and dark mode persistence"
```

Expected: analyzer and tests pass.

## Task 10: README, Manual QA, And Release Build

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update README**

README must include:

```txt
App name
Feature list
Tech stack
API base URL
Test account
How to run
How to build APK
Screenshot section
Demo video section
Known API/network notes
```

- [ ] **Step 2: Run full verification**

Run:

```bash
flutter analyze
flutter test
flutter build apk --release
```

Expected:

```txt
flutter analyze exits 0
flutter test exits 0
flutter build apk --release exits 0
```

- [ ] **Step 3: Manual QA checklist**

Complete this checklist on emulator or device:

```txt
Register valid and invalid input.
Login with mahasiswa@test.com / test123456.
Restart app and confirm auto-login.
Open and update profile.
Toggle dark mode and restart app.
Search products.
Filter category.
Sort products.
Scroll product pagination.
Open product detail.
Add review.
Toggle wishlist and restart app.
Open wishlist.
Add product to cart.
Update cart quantity.
Remove cart item.
Clear cart.
Checkout with invalid address.
Checkout with valid address.
Confirm local notification after success.
Open order history.
Open order detail.
Logout.
```

- [ ] **Step 4: Commit final docs**

```bash
git add README.md
git commit -m "docs: update ecommerce app README"
```

## Self-Review

Spec coverage:

```txt
Theme tokens: Task 2
Architecture: Tasks 1-4
Auth/Profile: Task 5
Product/Reviews: Task 6
Cart: Task 7
Checkout/Orders/Notification: Task 8
Wishlist/Dark Mode: Task 9
README/APK/manual QA: Task 10
```

Placeholder scan:

```txt
No unresolved marker strings.
No vague implementation steps.
No unspecified file paths.
```

Type consistency:

```txt
ProductModel is used by ProductProvider, CartItemModel, WishlistProvider, and ProductCard.
CartItemModel is used by CartProvider and OrderModel.
OrderModel displayNumber matches order history requirement.
ThemeProvider exposes isDarkMode for App and ProfilePage.
AuthProvider owns token/session state for SplashPage and ProfilePage.
```
