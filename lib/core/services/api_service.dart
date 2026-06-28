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

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await _storage.getToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final uri = Uri.parse('${ApiConstants.baseUrl}$path');
      final response = await switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'PUT' => _client.put(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        ),
        'DELETE' => _client.delete(uri, headers: headers),
        _ => throw const AppException('Metode request tidak valid.'),
      }.timeout(ApiConstants.connectTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw const AppException('Tidak ada koneksi internet.');
    } on TimeoutException {
      throw const AppException('Koneksi lambat. Coba lagi.');
    } on FormatException {
      throw const AppException('Format response tidak valid.');
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
