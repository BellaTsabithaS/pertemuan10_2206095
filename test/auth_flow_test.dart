// Purpose: Tests for auth service, auth provider, theme provider, and app shell routing.
// Main callers: flutter test.
// Key dependencies: flutter_test, SharedPreferences mock store, auth/theme classes.
// Main/public functions: AuthService, AuthProvider, ThemeProvider, App tests.
// Side effects: Uses in-memory SharedPreferences mock data and pumps widgets.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/app.dart';
import 'package:flutter_toko/core/services/api_service.dart';
import 'package:flutter_toko/core/services/auth_service.dart';
import 'package:flutter_toko/core/services/storage_service.dart';
import 'package:flutter_toko/providers/auth_provider.dart';
import 'package:flutter_toko/providers/theme_provider.dart';
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

      final token = await service.login('mahasiswa@test.com', 'test123456');

      expect(token, 'token-123');
      expect(api.lastPath, '/auth/login');
      expect(api.lastBody, {
        'email': 'mahasiswa@test.com',
        'password': 'test123456',
      });
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
    final api = FakeApiService()
      ..nextResponse = {
        'data': {'access_token': 'token-123'},
      };
    final provider = AuthProvider(authService: AuthService(api: api));

    final success = await provider.login('mahasiswa@test.com', 'test123456');

    expect(success, isTrue);
    expect(provider.token, 'token-123');
    expect(provider.isLoading, isFalse);
    expect(await StorageService.instance.getToken(), 'token-123');
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
}
