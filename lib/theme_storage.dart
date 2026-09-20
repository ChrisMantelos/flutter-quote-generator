import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const _key = 'is_dark_mode';

  Future<bool> loadIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> saveIsDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
