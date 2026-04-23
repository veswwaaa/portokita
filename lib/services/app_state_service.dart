import 'package:shared_preferences/shared_preferences.dart';

class AppStateService {
  static const String _lastRouteKey = 'last_route';
  static const String _isFirstLaunchKey = 'is_first_launch';

  /// Simpan route terakhir
  static Future<void> saveLastRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRouteKey, route);
  }

  /// Dapatkan route terakhir
  static Future<String?> getLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRouteKey);
  }

  /// Cek apakah first launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(_isFirstLaunchKey) ?? true;

    if (isFirst) {
      await prefs.setBool(_isFirstLaunchKey, false);
    }

    return isFirst;
  }

  /// Reset state saat logout
  static Future<void> resetAppState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRouteKey);
  }

  /// Clear last route (e.g., when user logs out)
  static Future<void> clearLastRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRouteKey);
  }
}
