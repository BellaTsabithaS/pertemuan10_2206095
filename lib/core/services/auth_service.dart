// Purpose: Auth/profile REST service for customer account flows.
// Main callers: AuthProvider.
// Key dependencies: ApiService, UserModel.
// Main/public functions: register, login, getProfile, updateProfile.
// Side effects: Performs HTTP requests through ApiService.

import '../../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  AuthService({ApiService? api}) : _api = api ?? ApiService();

  final ApiService _api;

  Future<void> register(String name, String email, String password) async {
    await _api.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<String> login(String email, String password) async {
    final response = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final data = _asMap(response);
    final nested = _asMap(data['data']);
    return '${nested['access_token'] ?? nested['token'] ?? data['access_token'] ?? data['token'] ?? ''}';
  }

  Future<UserModel> getProfile() async {
    final response = await _api.get('/auth/profile');
    return UserModel.fromJson(_extractData(response));
  }

  Future<UserModel> updateProfile(String name, String phone) async {
    final response = await _api.put(
      '/auth/profile',
      body: {'name': name, 'phone': phone},
    );
    return UserModel.fromJson(_extractData(response));
  }

  Map<String, dynamic> _extractData(dynamic response) {
    final data = _asMap(response);
    final nested = _asMap(data['data']);
    final user = _asMap(data['user']);
    if (nested.isNotEmpty) {
      return nested;
    }
    if (user.isNotEmpty) {
      return user;
    }
    return data;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }
}
