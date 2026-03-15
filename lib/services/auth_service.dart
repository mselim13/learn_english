import 'package:flutter/foundation.dart';

import 'app_prefs.dart';
import 'profile_notifier.dart';

enum LoginError {
  emptyEmail,
  noRegisteredUser,
  emailNotMatch,
}

class LoginResult {
  final bool success;
  final LoginError? error;

  const LoginResult._(this.success, this.error);

  factory LoginResult.success() => const LoginResult._(true, null);

  factory LoginResult.failure(LoginError error) =>
      LoginResult._(false, error);
}

enum RegisterError {
  emptyName,
  emptyEmail,
  weakPassword,
}

class RegisterResult {
  final bool success;
  final RegisterError? error;

  const RegisterResult._(this.success, this.error);

  factory RegisterResult.success() => const RegisterResult._(true, null);

  factory RegisterResult.failure(RegisterError error) =>
      RegisterResult._(false, error);
}

/// AuthService, kimlik ve profil bilgisini yöneten katman.
/// Şu anda local (SharedPreferences) kullanıyor; ileride backend'e geçerken
/// sadece bu sınıfın içi değiştirilerek UI korunabilir.
class AuthService {
  /// Kullanıcı kayıtlı mı ve giriş flag'i açık mı?
  static Future<bool> isAuthenticated() {
    return AppPrefs.isAuthenticated();
  }

  /// Sadece kayıtlı kullanıcı var mı (ad + e-posta)?
  static Future<bool> hasRegisteredUser() {
    return AppPrefs.hasRegisteredUser();
  }

  /// E-posta ile basit login.
  /// Şu anda sadece kayıtlı e-posta ile eşleşmeyi kontrol eder.
  static Future<LoginResult> loginWithEmail({
    required String email,
    required bool rememberMe,
  }) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return LoginResult.failure(LoginError.emptyEmail);
    }

    final registeredEmail = await AppPrefs.getUserEmail();
    if (registeredEmail == null || registeredEmail.isEmpty) {
      return LoginResult.failure(LoginError.noRegisteredUser);
    }

    if (trimmed.toLowerCase() != registeredEmail.toLowerCase()) {
      return LoginResult.failure(LoginError.emailNotMatch);
    }

    await AppPrefs.setLoggedIn(true);

    // Profil bilgisini notifier üzerinden tüm uygulamaya yay.
    final profile = await loadProfileFromPrefs();
    updateProfileNotifier(profile);

    if (rememberMe) {
      await AppPrefs.setRememberMe(true);
      await AppPrefs.setSavedEmail(trimmed.isEmpty ? null : trimmed);
    } else {
      await AppPrefs.setRememberMe(false);
      await AppPrefs.setSavedEmail(null);
    }

    return LoginResult.success();
  }

  /// Basit kayıt akışı.
  /// Şu an localde ad + e-posta + parola kontrolü yapar ve giriş flag'ini açar.
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

    await AppPrefs.setUserName(trimmedName);
    await AppPrefs.setUserEmail(trimmedEmail);
    await AppPrefs.setLoggedIn(true);

    updateProfileNotifier(
      ProfileData(name: trimmedName, level: 'A2', email: trimmedEmail),
    );

    return RegisterResult.success();
  }

  /// Profil düzenlemeden gelen güncellemeleri kaydeder ve yayar.
  static Future<void> updateProfile({
    required String? name,
    required String? email,
    required String level,
  }) async {
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

  /// Güvenli çıkış: flag'i kapatır ve profili temizler.
  static Future<void> logout() async {
    await AppPrefs.setLoggedIn(false);
    profileNotifier.value = null;
  }

  /// Sadece avatarı güncelle.
  static Future<void> updateAvatar(String? path) async {
    await AppPrefs.setAvatarPath(path);
    final current = profileNotifier.value ?? await loadProfileFromPrefs();
    updateProfileNotifier(current.copyWith(avatarPath: path));
  }
}

