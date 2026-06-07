import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'api_service.dart';
import 'app_prefs.dart';
import 'profile_notifier.dart';

enum LoginError {
  emptyEmail,
  emptyPassword,
  invalidCredentials,
  networkError,
  emailAlreadyInUse,
}

class LoginResult {
  final bool success;
  final LoginError? error;

  const LoginResult._(this.success, this.error);

  factory LoginResult.success() => const LoginResult._(true, null);
  factory LoginResult.failure(LoginError error) => LoginResult._(false, error);
}

enum RegisterError {
  emptyName,
  emptyEmail,
  weakPassword,
  emailAlreadyInUse,
  networkError,
}

class RegisterResult {
  final bool success;
  final RegisterError? error;

  const RegisterResult._(this.success, this.error);

  factory RegisterResult.success() => const RegisterResult._(true, null);
  factory RegisterResult.failure(RegisterError error) =>
      RegisterResult._(false, error);
}

/// AuthService — tüm kimlik doğrulama ve profil işlemlerini yönetir.
/// Backend: Node.js/Express + MongoDB Atlas. Oturumlar JWT ile korunur.
class AuthService {
  static Future<bool> isAuthenticated() async {
    final loggedIn = await AppPrefs.getLoggedIn();
    if (!loggedIn) return false;
    final token = await AppPrefs.getAccessToken();
    return token != null;
  }

  static Future<bool> hasRegisteredUser() => AppPrefs.hasRegisteredUser();

  /// Backend'den güncel kullanıcı bilgilerini çeker ve yerel önbelleği günceller.
  /// Hata olursa sessizce geçer (yerel veri korunur).
  static Future<void> fetchAndSyncUser() async {
    try {
      final res = await ApiService.get('/auth/me');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final user = body['user'] as Map<String, dynamic>?;
        if (user != null) await _syncUserToPrefs(user);
      }
    } catch (_) {}
  }

  static Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return LoginResult.failure(LoginError.emptyEmail);
    }
    if (password.isEmpty) {
      return LoginResult.failure(LoginError.emptyPassword);
    }

    try {
      final res = await ApiService.post(
        '/auth/login',
        {'email': trimmedEmail, 'password': password},
        auth: false,
      );

      if (res.statusCode == 401) {
        return LoginResult.failure(LoginError.invalidCredentials);
      }
      if (res.statusCode != 200) {
        return LoginResult.failure(LoginError.networkError);
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      await _saveSession(body, rememberMe: rememberMe, email: trimmedEmail);
      return LoginResult.success();
    } catch (_) {
      return LoginResult.failure(LoginError.networkError);
    }
  }

  static Future<RegisterResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      return RegisterResult.failure(RegisterError.emptyName);
    }
    if (trimmedEmail.isEmpty) {
      return RegisterResult.failure(RegisterError.emptyEmail);
    }
    if (password.length < 6) {
      return RegisterResult.failure(RegisterError.weakPassword);
    }

    try {
      final res = await ApiService.post(
        '/auth/register',
        {'name': trimmedName, 'email': trimmedEmail, 'password': password},
        auth: false,
      );

      if (res.statusCode == 409) {
        return RegisterResult.failure(RegisterError.emailAlreadyInUse);
      }
      if (res.statusCode != 201) {
        return RegisterResult.failure(RegisterError.networkError);
      }

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      await _saveSession(body, rememberMe: false, email: trimmedEmail);
      return RegisterResult.success();
    } catch (_) {
      return RegisterResult.failure(RegisterError.networkError);
    }
  }

  /// Login veya register sonrası ortak oturum kayıt işlemi.
  static Future<void> _saveSession(
    Map<String, dynamic> body, {
    required bool rememberMe,
    required String email,
  }) async {
    final accessToken = body['accessToken'] as String;
    final refreshToken = body['refreshToken'] as String;
    final user = body['user'] as Map<String, dynamic>;

    await AppPrefs.setAccessToken(accessToken);
    await AppPrefs.setRefreshToken(refreshToken);
    await AppPrefs.setLoggedIn(true);

    await _syncUserToPrefs(user);

    if (rememberMe) {
      await AppPrefs.setRememberMe(true);
      await AppPrefs.setSavedEmail(email);
    } else {
      await AppPrefs.setRememberMe(false);
      await AppPrefs.setSavedEmail(null);
    }

    final profile = await loadProfileFromPrefs();
    updateProfileNotifier(profile);
  }

  /// Backend'den gelen kullanıcı verisini yerel önbelleğe yazar.
  static Future<void> _syncUserToPrefs(Map<String, dynamic> user) async {
    await AppPrefs.setUserName(user['name'] as String?);
    await AppPrefs.setUserEmail(user['email'] as String?);
    await AppPrefs.setUserLevel((user['level'] as String?) ?? 'A2');

    if (user['membershipJoinedAt'] != null) {
      final joinedAt =
          DateTime.tryParse(user['membershipJoinedAt'] as String) ??
              DateTime.now();
      await AppPrefs.setMembershipJoinedAtMs(
          joinedAt.millisecondsSinceEpoch);
    } else {
      await AppPrefs.ensureMembershipDateIfMissing();
    }

    if (user['dailyGoalMinutes'] != null) {
      await AppPrefs.setDailyGoalMinutes(user['dailyGoalMinutes'] as int);
    }
    if (user['placementTestCompleted'] != null) {
      await AppPrefs.setPlacementTestCompleted(
          user['placementTestCompleted'] as bool);
    }
    if (user['placementTestScore'] != null) {
      await AppPrefs.setPlacementTestScore(user['placementTestScore'] as int);
    }
    if (user['notificationsEnabled'] != null) {
      await AppPrefs.setNotificationsEnabled(
          user['notificationsEnabled'] as bool);
    }
    if (user['dailyReminderEnabled'] != null) {
      await AppPrefs.setDailyReminderEnabled(
          user['dailyReminderEnabled'] as bool);
    }
    if (user['dailyReminderTimeMinutes'] != null) {
      await AppPrefs.setDailyReminderTimeMinutes(
          user['dailyReminderTimeMinutes'] as int);
    }
    if (user['soundEffectsEnabled'] != null) {
      await AppPrefs.setSoundEffectsEnabled(user['soundEffectsEnabled'] as bool);
    }
    if (user['darkMode'] != null) {
      await AppPrefs.setDarkMode(user['darkMode'] as bool);
    }
  }

  /// Profil ve ayar güncellemesi — hem backend'e hem yerel önbelleğe yazar.
  static Future<void> updateProfile({
    required String? name,
    required String? email,
    required String level,
    bool? placementTestCompleted,
    int? placementTestScore,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
    if (email != null && email.trim().isNotEmpty) {
      updates['email'] = email.trim();
    }
    updates['level'] = level;
    if (placementTestCompleted != null) {
      updates['placementTestCompleted'] = placementTestCompleted;
    }
    if (placementTestScore != null) {
      updates['placementTestScore'] = placementTestScore;
    }

    try {
      final res = await ApiService.put('/auth/profile', updates);
      if (res.statusCode == 200) {
        final user =
            (jsonDecode(res.body) as Map<String, dynamic>)['user']
                as Map<String, dynamic>;
        await _syncUserToPrefs(user);
      }
    } catch (_) {}

    // Her durumda yerel önbelleği güncelle.
    await AppPrefs.setUserName(name);
    await AppPrefs.setUserEmail(email);
    await AppPrefs.setUserLevel(level);

    final avatarPath = await AppPrefs.getAvatarPath();
    updateProfileNotifier(
      ProfileData(
        name: name,
        level: level,
        email: email,
        avatarPath: avatarPath,
      ),
    );
  }

  /// Güvenli çıkış: backend'i bilgilendirir ve yerel oturumu temizler.
  static Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (_) {}
    await AppPrefs.setAccessToken(null);
    await AppPrefs.setRefreshToken(null);
    await AppPrefs.setLoggedIn(false);
    await AppPrefs.setPlacementTestCompleted(false);
    await AppPrefs.setPlacementTestScore(0);
    profileNotifier.value = null;
  }

  /// Hesabı hem backend'den hem cihazdan tamamen siler.
  static Future<void> deleteAllLocalDataAndSignOut() async {
    try {
      await ApiService.delete('/auth/account');
    } catch (_) {}

    final avatarPath = await AppPrefs.getAvatarPath();
    if (avatarPath != null && avatarPath.trim().isNotEmpty) {
      try {
        final f = File(avatarPath.trim());
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    try {
      final docs = await getApplicationDocumentsDirectory();
      final profileDir = Directory('${docs.path}/profile');
      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
      }
    } catch (_) {}

    await AppPrefs.clearAll();
    profileNotifier.value = null;
  }

  /// Şifre sıfırlama OTP'si gönderir.
  static Future<({bool success, String? error})> forgotPassword(
      String email) async {
    try {
      final res = await ApiService.post(
        '/auth/forgot-password',
        {'email': email.trim()},
        auth: false,
      );
      if (res.statusCode == 200) return (success: true, error: null);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (success: false, error: body['message'] as String?);
    } catch (_) {
      return (success: false, error: 'Sunucuya bağlanılamadı.');
    }
  }

  /// OTP ile parolayı sıfırlar.
  static Future<({bool success, String? error})> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await ApiService.post(
        '/auth/reset-password',
        {'email': email.trim(), 'otp': otp.trim(), 'newPassword': newPassword},
        auth: false,
      );
      if (res.statusCode == 200) return (success: true, error: null);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return (success: false, error: body['message'] as String?);
    } catch (_) {
      return (success: false, error: 'Sunucuya bağlanılamadı.');
    }
  }

  /// Sadece avatarı güncelle (avatar sunucuya yüklenmez; yerel kalır).
  static Future<void> updateAvatar(String? path) async {
    if (path == null || path.trim().isEmpty) {
      await AppPrefs.setAvatarPath(null);
      final current = profileNotifier.value ?? await loadProfileFromPrefs();
      updateProfileNotifier(current.copyWith(avatarPath: null));
      return;
    }

    final src = File(path);
    if (!await src.exists()) {
      throw StateError('Seçilen fotoğraf bulunamadı.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${dir.path}/profile');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    final dst = File('${avatarDir.path}/avatar.jpg');
    await src.copy(dst.path);

    await AppPrefs.setAvatarPath(dst.path);
    final current = profileNotifier.value ?? await loadProfileFromPrefs();
    updateProfileNotifier(current.copyWith(avatarPath: dst.path));
  }
}
