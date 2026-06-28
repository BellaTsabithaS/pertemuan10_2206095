// Purpose: Tests for core API, exception, and storage services.
// Main callers: flutter test.
// Key dependencies: flutter_test, http MockClient, SharedPreferences mock store.
// Main/public functions: ApiService and StorageService behavior tests.
// Side effects: Uses in-memory SharedPreferences mock data.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_toko/core/exceptions/app_exception.dart';
import 'package:flutter_toko/core/services/api_service.dart';
import 'package:flutter_toko/core/services/storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('StorageService saves and clears token', () async {
    await StorageService.instance.saveToken('abc123');

    expect(await StorageService.instance.getToken(), 'abc123');

    await StorageService.instance.clearToken();

    expect(await StorageService.instance.getToken(), isNull);
  });

  test('ApiService decodes success JSON and sends bearer token', () async {
    await StorageService.instance.saveToken('abc123');
    http.Request? capturedRequest;
    final api = ApiService(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response('{"ok":true}', 200);
      }),
    );

    final response = await api.get('/profile');

    expect(response, {'ok': true});
    expect(capturedRequest?.headers['Authorization'], 'Bearer abc123');
    expect(capturedRequest?.url.path, endsWith('/api/profile'));
  });

  test('ApiService maps 401 response to unauthorized AppException', () async {
    final api = ApiService(
      client: MockClient(
        (_) async => http.Response('{"message":"Session expired"}', 401),
      ),
    );

    await expectLater(
      api.get('/profile'),
      throwsA(
        isA<AppException>()
            .having((error) => error.message, 'message', 'Session expired')
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.isUnauthorized, 'isUnauthorized', true),
      ),
    );
  });
}
