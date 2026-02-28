import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyDarkMode = 'dark_mode';
  static const _keyRememberMe = 'remember_me';
  static const _keySavedEmail = 'saved_email';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<bool> getOnboardingSeen() async {
    final p = await _prefs;
    return p.getBool(_keyOnboardingSeen) ?? false;
  }

  static Future<void> setOnboardingSeen(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyOnboardingSeen, value);
  }

  static Future<bool> getDarkMode() async {
    final p = await _prefs;
    return p.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyDarkMode, value);
  }

  static Future<bool> getRememberMe() async {
    final p = await _prefs;
    return p.getBool(_keyRememberMe) ?? false;
  }

  static Future<void> setRememberMe(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyRememberMe, value);
  }

  static Future<String?> getSavedEmail() async {
    final p = await _prefs;
    return p.getString(_keySavedEmail);
  }

  static Future<void> setSavedEmail(String? value) async {
    final p = await _prefs;
    if (value == null) {
      await p.remove(_keySavedEmail);
    } else {
      await p.setString(_keySavedEmail, value);
    }
  }
}
