import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyDarkMode = 'dark_mode';
  static const _keyRememberMe = 'remember_me';
  static const _keySavedEmail = 'saved_email';
  static const _keyUserName = 'user_name';
  static const _keyUserLevel = 'user_level';
  static const _keyUserEmail = 'user_email';
  static const _keyLoggedIn = 'logged_in';

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

  static Future<String?> getUserName() async {
    final p = await _prefs;
    return p.getString(_keyUserName);
  }

  static Future<void> setUserName(String? value) async {
    final p = await _prefs;
    if (value == null || value.trim().isEmpty) {
      await p.remove(_keyUserName);
    } else {
      await p.setString(_keyUserName, value.trim());
    }
  }

  static Future<String> getUserLevel() async {
    final p = await _prefs;
    return p.getString(_keyUserLevel) ?? 'A2';
  }

  static Future<void> setUserLevel(String value) async {
    final p = await _prefs;
    await p.setString(_keyUserLevel, value);
  }

  static Future<String?> getUserEmail() async {
    final p = await _prefs;
    return p.getString(_keyUserEmail);
  }

  static Future<void> setUserEmail(String? value) async {
    final p = await _prefs;
    if (value == null || value.trim().isEmpty) {
      await p.remove(_keyUserEmail);
    } else {
      await p.setString(_keyUserEmail, value.trim());
    }
  }

  static Future<bool> getLoggedIn() async {
    final p = await _prefs;
    return p.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyLoggedIn, value);
  }

  /// Gerçekten kayıtlı kullanıcı var mı (ad + e-posta kaydedilmiş)
  static Future<bool> hasRegisteredUser() async {
    final name = await getUserName();
    final email = await getUserEmail();
    return (name != null && name.trim().isNotEmpty) &&
        (email != null && email.trim().isNotEmpty);
  }

  /// Giriş yapılmış ve geçerli mi (hem flag hem kayıtlı kullanıcı)
  static Future<bool> isAuthenticated() async {
    final loggedIn = await getLoggedIn();
    if (!loggedIn) return false;
    return hasRegisteredUser();
  }
}
