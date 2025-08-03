import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool getBool(String key) => _prefs.getBool(key) ?? false;

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
}

