import 'package:flutter/foundation.dart';
import 'app_prefs.dart';

class ProfileData {
  final String? name;
  final String level;
  final String? email;

  ProfileData({this.name, required this.level, this.email});

  String get displayName => (name != null && name!.trim().isNotEmpty) ? name! : 'Kullanıcı';
  String get displayTitle => '$displayName - $level';
}

final profileNotifier = ValueNotifier<ProfileData?>(null);

Future<ProfileData> loadProfileFromPrefs() async {
  final name = await AppPrefs.getUserName();
  final level = await AppPrefs.getUserLevel();
  final email = await AppPrefs.getUserEmail();
  return ProfileData(name: name, level: level, email: email);
}

void updateProfileNotifier(ProfileData data) {
  profileNotifier.value = data;
}
