// Purpose: Tests for auth service, auth provider, theme provider, and app shell routing.
// Main callers: flutter test.
// Key dependencies: flutter_test, SharedPreferences mock store, auth/theme classes.
// Main/public functions: AuthService, AuthProvider, ThemeProvider, App tests.
// Side effects: Uses in-memory SharedPreferences mock data and pumps widgets.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/app.dart';
import 'package:flutter_toko/core/services/admin_service.dart';
import 'package:flutter_toko/core/services/api_service.dart';
import 'package:flutter_toko/core/services/auth_service.dart';
import 'package:flutter_toko/core/services/storage_service.dart';
import 'package:flutter_toko/features/auth/login_page.dart';
import 'package:flutter_toko/models/category_model.dart';
import 'package:flutter_toko/models/order_model.dart';
import 'package:flutter_toko/models/user_model.dart';
import 'package:flutter_toko/providers/admin_provider.dart';
import 'package:flutter_toko/providers/auth_provider.dart';
import 'package:flutter_toko/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}

class FakeAuthService extends AuthService {
  FakeAuthService() : super(api: FakeApiService());

  @override
  Future<AuthLoginResult> login(String email, String password) async {
    return AuthLoginResult(
      token: 'token-123',
      user: UserModel.fromJson({
        'id': 'u1',
        'email': 'admin@example.com',
        'full_name': 'Admin User',
        'role': 'admin',
      }),
    );
  }
}

class FakeAdminService extends AdminService {
  FakeAdminService() : super(api: FakeApiService());

  @override
  Future<Map<String, dynamic>> fetchStats() async => {};

  @override
  Future<List<Map<String, dynamic>>> fetchLowStock({int threshold = 10}) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTopProducts({int limit = 5}) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecentOrders({int limit = 5}) async {
    return [];
  }

  @override
  Future<List<OrderModel>> fetchOrders({
    String status = '',
    int page = 1,
  }) async {
    return [];
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async => [];
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'AuthService login posts credentials and returns access token',
    () async {
      final api = FakeApiService()
        ..nextResponse = {
          'data': {'access_token': 'token-123'},
        };
      final service = AuthService(api: api);

      final result = await service.login('mahasiswa@test.com', 'test123456');

      expect(result.token, 'token-123');
      expect(api.lastPath, '/auth/login');
      expect(api.lastBody, {
        'email': 'mahasiswa@test.com',
        'password': 'test123456',
      });
    },
  );

  test(
    'AuthService login parses admin user from login response payload',
    () async {
      final api = FakeApiService()
        ..nextResponse = {
          'data': {
            'access_token': 'token-123',
            'refresh_token': 'refresh-123',
            'user': {
              'id': '8c2f60bb-ebf6-4c5e-808e-2813576747e3',
              'email': 'admin@admin.com',
              'full_name': 'John Updated',
              'phone': '08123456789',
              'role': 'admin',
            },
          },
        };
      final service = AuthService(api: api);

      final result = await service.login('admin@admin.com', 'password123');

      expect(result.token, 'token-123');
      expect(result.user?.email, 'admin@admin.com');
      expect(result.user?.isAdmin, isTrue);
    },
  );

  test(
    'AuthService register posts full_name payload required by API',
    () async {
      final api = FakeApiService()
        ..nextResponse = {'success': true, 'message': 'Registrasi berhasil.'};
      final service = AuthService(api: api);

      await service.register('John Doe', 'user@example.com', 'password123');

      expect(api.lastPath, '/auth/register');
      expect(api.lastBody, {
        'email': 'user@example.com',
        'password': 'password123',
        'full_name': 'John Doe',
      });
    },
  );

  test(
    'AuthService updateProfile posts full_name payload required by API',
    () async {
      final api = FakeApiService()
        ..nextResponse = {
          'data': {
            'id': 'u1',
            'email': 'user@example.com',
            'full_name': 'John Doe',
            'phone': '081234567890',
          },
        };
      final service = AuthService(api: api);

      final user = await service.updateProfile('John Doe', '081234567890');

      expect(user.name, 'John Doe');
      expect(api.lastPath, '/auth/profile');
      expect(api.lastBody, {'full_name': 'John Doe', 'phone': '081234567890'});
    },
  );

  test('AuthProvider login saves token and clears loading state', () async {
    final provider = AuthProvider(authService: FakeAuthService());

    final success = await provider.login('mahasiswa@test.com', 'test123456');

    expect(success, isTrue);
    expect(provider.token, 'token-123');
    expect(provider.user?.isAdmin, isTrue);
    expect(provider.isLoading, isFalse);
    expect(await StorageService.instance.getToken(), 'token-123');
  });

  test('UserModel parses role from login and profile response shapes', () {
    final loginUser = UserModel.fromJson({
      'id': 'u1',
      'email': 'admin@example.com',
      'full_name': 'Admin User',
      'role': 'admin',
    });
    final profileUser = UserModel.fromJson({
      'id': 'u2',
      'email': 'admin2@example.com',
      'full_name': 'Admin Two',
      'role': {'name': 'admin'},
    });

    expect(loginUser.role, 'admin');
    expect(loginUser.isAdmin, isTrue);
    expect(profileUser.role, 'admin');
    expect(profileUser.isAdmin, isTrue);
  });

  test('ThemeProvider loads and persists dark mode preference', () async {
    SharedPreferences.setMockInitialValues({'is_dark_mode': true});
    final provider = ThemeProvider();

    await provider.loadTheme();

    expect(provider.isDarkMode, isTrue);

    await provider.toggleTheme();

    expect(provider.isDarkMode, isFalse);
    expect(await StorageService.instance.getDarkMode(), isFalse);
  });

  testWidgets('App shows login page when no token exists', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('LoginPage routes admin user to AdminHomePage', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(authService: FakeAuthService()),
          ),
          ChangeNotifierProvider(
            create: (_) => AdminProvider(adminService: FakeAdminService()),
          ),
        ],
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'admin@admin.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Masuk').last);
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(TabBar), findsNothing);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Pesanan'), findsWidgets);
    expect(find.text('Kategori'), findsWidgets);
    expect(find.text('Produk'), findsWidgets);
  });
}
