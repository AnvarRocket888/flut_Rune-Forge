import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw StateError('StorageService not initialized');
    return _prefs!;
  }

  static Future<void> setString(String key, String value) =>
      prefs.setString(key, value);

  static String? getString(String key) => prefs.getString(key);

  static Future<void> setInt(String key, int value) =>
      prefs.setInt(key, value);

  static int? getInt(String key) => prefs.getInt(key);

  static Future<void> setBool(String key, bool value) =>
      prefs.setBool(key, value);

  static bool? getBool(String key) => prefs.getBool(key);

  static Future<void> remove(String key) => prefs.remove(key);

  static Future<void> clear() => prefs.clear();

  // Keys
  static const kProfile = 'user_profile';
  static const kRunes = 'runes';
  static const kSpells = 'spells';
  static const kTower = 'tower_floors';
  static const kAchievements = 'achievements';
  static const kTrophies = 'trophies';
  static const kLastRuneDrop = 'last_rune_drop';
  static const kLastEnergyRecovery = 'last_energy_recovery';
}
