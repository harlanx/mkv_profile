import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  //This class is a singleton of sharedpreferences, so we don't have to create a new instance everytime we need it.
  static late final SharedPreferences _prefs;

  //IMPORTANT: Initialize this to the function of main().
  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();

    if (kDebugMode) {
      // Clear on debug mode.
      _prefs.clear();
    }
    return _prefs;
  }

  //Setter Methods
  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  //Getter Methods
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  //Delete Methods
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
