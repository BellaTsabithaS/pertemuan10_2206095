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
