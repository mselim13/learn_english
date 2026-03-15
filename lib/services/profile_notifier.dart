import 'package:flutter/foundation.dart';
import 'app_prefs.dart';

class ProfileData {
  final String? name;
  final String level;
  final String? email;
  final String? avatarPath;

  ProfileData({
    this.name,
    required this.level,
    this.email,
    this.avatarPath,
  });

  String get displayName =>
      (name != null && name!.trim().isNotEmpty) ? name! : 'Kullanıcı';

  String get displayTitle => '$displayName - $level';

  bool get hasAvatar =>
      avatarPath != null && avatarPath!.trim().isNotEmpty;

  ProfileData copyWith({
    String? name,
    String? level,
    String? email,
    String? avatarPath,
  }) {
    return ProfileData(
      name: name ?? this.name,
      level: level ?? this.level,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}

final profileNotifier = ValueNotifier<ProfileData?>(null);

Future<ProfileData> loadProfileFromPrefs() async {
  final name = await AppPrefs.getUserName();
  final level = await AppPrefs.getUserLevel();
  final email = await AppPrefs.getUserEmail();
  final avatarPath = await AppPrefs.getAvatarPath();
  return ProfileData(
    name: name,
    level: level,
    email: email,
    avatarPath: avatarPath,
  );
}

void updateProfileNotifier(ProfileData data) {
  profileNotifier.value = data;
}
