// Purpose: Theme state provider for light/dark mode preference.
// Main callers: App, ProfilePage.
// Key dependencies: ChangeNotifier, StorageService.
// Main/public functions: loadTheme, toggleTheme.
// Side effects: Reads and writes dark mode preference in SharedPreferences.

import 'package:flutter/foundation.dart';

import '../core/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({StorageService? storage})
    : _storage = storage ?? StorageService.instance;

  final StorageService _storage;

  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  Future<void> loadTheme() async {
    _isLoading = true;
    notifyListeners();
    _isDarkMode = await _storage.getDarkMode();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storage.saveDarkMode(_isDarkMode);
  }
}
