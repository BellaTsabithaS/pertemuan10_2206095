// Purpose: Auth state provider for login, register, profile, and logout flows.
// Main callers: App, SplashPage, LoginPage, RegisterPage, ProfilePage.
// Key dependencies: ChangeNotifier, AuthService, StorageService, AppException.
// Main/public functions: checkLoginStatus, register, login, logout, getProfile, updateProfile.
// Side effects: Reads/writes auth token and performs auth/profile HTTP calls.

import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, StorageService? storage})
    : _authService = authService ?? AuthService(),
      _storage = storage ?? StorageService.instance;

  final AuthService _authService;
  final StorageService _storage;

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> checkLoginStatus() async {
    _setLoading(true);
    _token = await _storage.getToken();
    if (!isAuthenticated) {
      _setLoading(false);
      return;
    }

    try {
      _user = await _authService.getProfile();
    } on AppException catch (error) {
      if (error.isUnauthorized) {
        await logout();
      } else {
        _errorMessage = error.message;
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    return _run(() async {
      await _authService.register(name, email, password);
    });
  }

  Future<bool> login(String email, String password) async {
    return _run(() async {
      final accessToken = await _authService.login(email, password);
      if (accessToken.isEmpty) {
        throw const AppException('Token login tidak ditemukan.');
      }
      _token = accessToken;
      await _storage.saveToken(accessToken);
    });
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _errorMessage = null;
    await _storage.clearToken();
    notifyListeners();
  }

  Future<bool> getProfile() async {
    return _run(() async {
      _user = await _authService.getProfile();
    });
  }

  Future<bool> updateProfile(String name, String phone) async {
    return _run(() async {
      _user = await _authService.updateProfile(name, phone);
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await action();
      return true;
    } on AppException catch (error) {
      _errorMessage = error.message;
      if (error.isUnauthorized) {
        await logout();
      }
      return false;
    } catch (_) {
      _errorMessage = 'Terjadi kesalahan. Coba lagi.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
