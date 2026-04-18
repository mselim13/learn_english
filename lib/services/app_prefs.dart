import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyDarkMode = 'dark_mode';
  static const _keyRememberMe = 'remember_me';
  static const _keySavedEmail = 'saved_email';
  static const _keyUserName = 'user_name';
  static const _keyUserLevel = 'user_level';
  static const _keyPlacementTestCompleted = 'placement_test_completed';
  static const _keyPlacementTestScore = 'placement_test_score';
  static const _keyUserEmail = 'user_email';
  static const _keyLoggedIn = 'logged_in';
  static const _keyAvatarPath = 'avatar_path';
  static const _keyMembershipJoinedAtMs = 'membership_joined_at_ms';
  static const _keyDailyGoalMinutes = 'daily_goal_minutes';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyDailyReminderEnabled = 'notifications_daily_reminder_enabled';
  static const _keyDailyReminderTimeMinutes = 'notifications_daily_reminder_time_minutes';

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

  static Future<bool> getPlacementTestCompleted() async {
    final p = await _prefs;
    return p.getBool(_keyPlacementTestCompleted) ?? false;
  }

  static Future<void> setPlacementTestCompleted(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyPlacementTestCompleted, value);
  }

  static Future<int?> getPlacementTestScore() async {
    final p = await _prefs;
    return p.getInt(_keyPlacementTestScore);
  }

  static Future<void> setPlacementTestScore(int score) async {
    final p = await _prefs;
    await p.setInt(_keyPlacementTestScore, score);
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

   static Future<String?> getAvatarPath() async {
     final p = await _prefs;
     return p.getString(_keyAvatarPath);
   }

   static Future<void> setAvatarPath(String? value) async {
     final p = await _prefs;
     if (value == null || value.trim().isEmpty) {
       await p.remove(_keyAvatarPath);
     } else {
       await p.setString(_keyAvatarPath, value);
     }
   }

  static Future<int> getDailyGoalMinutes() async {
    final p = await _prefs;
    return p.getInt(_keyDailyGoalMinutes) ?? 20;
  }

  static Future<void> setDailyGoalMinutes(int minutes) async {
    final p = await _prefs;
    await p.setInt(_keyDailyGoalMinutes, minutes.clamp(5, 240));
  }

  static Future<bool> getNotificationsEnabled() async {
    final p = await _prefs;
    return p.getBool(_keyNotificationsEnabled) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyNotificationsEnabled, value);
  }

  static Future<bool> getDailyReminderEnabled() async {
    final p = await _prefs;
    return p.getBool(_keyDailyReminderEnabled) ?? true;
  }

  static Future<void> setDailyReminderEnabled(bool value) async {
    final p = await _prefs;
    await p.setBool(_keyDailyReminderEnabled, value);
  }

  /// Minutes since midnight (0..1439). Default 20:00.
  static Future<int> getDailyReminderTimeMinutes() async {
    final p = await _prefs;
    return (p.getInt(_keyDailyReminderTimeMinutes) ?? (20 * 60)).clamp(0, 1439);
  }

  static Future<void> setDailyReminderTimeMinutes(int minutes) async {
    final p = await _prefs;
    await p.setInt(_keyDailyReminderTimeMinutes, minutes.clamp(0, 1439));
  }

  /// İlk kayıt / ilk giriş anı (milisaniye epoch).
  static Future<int?> getMembershipJoinedAtMs() async {
    final p = await _prefs;
    final v = p.getInt(_keyMembershipJoinedAtMs);
    return v;
  }

  static Future<void> setMembershipJoinedAtMs(int ms) async {
    final p = await _prefs;
    await p.setInt(_keyMembershipJoinedAtMs, ms);
  }

  /// Daha önce kayıtlı değilse bugünü üyelik başlangıcı olarak kaydeder.
  static Future<void> ensureMembershipDateIfMissing() async {
    final existing = await getMembershipJoinedAtMs();
    if (existing != null) return;
    await setMembershipJoinedAtMs(DateTime.now().millisecondsSinceEpoch);
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
