import 'package:shared_preferences/shared_preferences.dart';

class EtokPrivacyService {
  static const String _keyPrefix = 'etok_privacy_';

  Future<void> saveSetting(String userId, String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool('${_keyPrefix}${userId}_$key', value);
    if (value is String) await prefs.setString('${_keyPrefix}${userId}_$key', value);
    if (value is int) await prefs.setInt('${_keyPrefix}${userId}_$key', value);
    if (value is List<String>) await prefs.setStringList('${_keyPrefix}${userId}_$key', value);
  }

  Future<dynamic> getSetting(String userId, String key, dynamic defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = '${_keyPrefix}${userId}_$key';
    if (defaultValue is bool) return prefs.getBool(fullKey) ?? defaultValue;
    if (defaultValue is String) return prefs.getString(fullKey) ?? defaultValue;
    if (defaultValue is int) return prefs.getInt(fullKey) ?? defaultValue;
    if (defaultValue is List<String>) return prefs.getStringList(fullKey) ?? defaultValue;
    return defaultValue;
  }
}
