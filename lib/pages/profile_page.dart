import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/responsive.dart';
import '../utils/turkish_date.dart';
import '../services/app_prefs.dart';
import '../services/auth_service.dart';
import '../services/profile_notifier.dart';
import 'settings_page.dart';
import 'edit_profile_page.dart';
import 'notification_settings_page.dart';
import 'level_roadmap_page.dart';
import 'daily_goal_page.dart';
import 'badges_page.dart';
import 'help_faq_page.dart';
import 'translate_page.dart';
import 'welcome_page.dart';
import 'crop_photo.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _primary = Color(0xFF4A148C);
  static const Color _primaryLight = Color(0xFFD1BEEB);
  static const Color _surface = Color(0xFFF5F0FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: Responsive.verticalPadding(context),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: Responsive.gapLg(context)),
              _buildProfileCard(context),
              SizedBox(height: Responsive.gapMd(context)),
              _buildStatsRow(context),
              SizedBox(height: Responsive.gapLg(context)),
              _buildSectionTitle(context, 'Hesap'),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.person_outline,
                title: 'Profil düzenle',
                subtitle: 'İsim, fotoğraf, seviye',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.notifications_outlined,
                title: 'Bildirimler',
                subtitle: 'Hatırlatmalar ve bildirimler',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage())),
              ),
              SizedBox(height: Responsive.gapLg(context)),
              _buildSectionTitle(context, 'Öğrenme'),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.translate_outlined,
                title: 'Çeviri / Sözlük',
                subtitle: 'Kelime veya ifade çevir',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslatePage())),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.map_outlined,
                title: 'Seviye yol haritası',
                subtitle: 'A1\'den C2\'ye ilerleme',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelRoadmapPage())),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.flag_outlined,
                title: 'Günlük hedef',
                subtitle: 'Hedef süre ve ilerleme',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyGoalPage())),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.workspace_premium_outlined,
                title: 'Rozetler',
                subtitle: 'Kazandığın başarılar',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesPage())),
              ),
              SizedBox(height: Responsive.gapLg(context)),
              _buildSectionTitle(context, 'Uygulama'),
              SizedBox(height: Responsive.gapSm(context)),
              _buildOptionCard(
                context,
                icon: Icons.help_outline,
                title: 'Yardım ve destek',
                subtitle: 'SSS, iletişim',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqPage())),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              SizedBox(height: Responsive.gapXl(context)),
              _buildLogoutButton(context),
              SizedBox(height: Responsive.gapLg(context)),
            ],
          ),
        ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Profilim',
          style: TextStyle(
            fontSize: Responsive.fontSizeTitle(context),
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
          icon: Icon(Icons.settings_outlined, color: _primary, size: Responsive.iconSizeMedium(context)),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final pad = Responsive.cardPadding(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ValueListenableBuilder<ProfileData?>(
            valueListenable: profileNotifier,
            builder: (context, data, _) {
              final hasAvatar = data?.hasAvatar ?? false;
              final ImageProvider? image = hasAvatar
                  ? FileImage(File(data!.avatarPath!))
                  : null;
              return Stack(
                key: ValueKey(data?.avatarPath ?? 'no-avatar'),
                children: [
                  CircleAvatar(
                    key: ValueKey(data?.avatarPath ?? 'no-avatar'),
                    radius: Responsive.avatarSize(context) / 2,
                    backgroundColor: _primaryLight,
                    backgroundImage: image,
                    child: image == null
                        ? Icon(
                            Icons.person,
                            color: Colors.white.withOpacity(0.9),
                            size: Responsive.avatarSize(context),
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _changeAvatar(context),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.gapSm(context)),
                        decoration: const BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: Responsive.iconSizeSmall(context),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: Responsive.gapMd(context)),
          ValueListenableBuilder<ProfileData?>(
            valueListenable: profileNotifier,
            builder: (context, data, _) {
              if (data != null) {
                return Column(
                  children: [
                    Text(
                      data.displayName,
                      style: TextStyle(
                        fontSize: Responsive.fontSizeTitle(context),
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                    SizedBox(height: Responsive.gapXs(context) * 1.5),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.gapMd(context),
                        vertical: Responsive.gapXs(context) * 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                      ),
                      child: Text(
                        'Seviye ${data.level}',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeBodySmall(context),
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return FutureBuilder<ProfileData>(
                future: loadProfileFromPrefs(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (profileNotifier.value == null) {
                        profileNotifier.value = snapshot.data;
                      }
                    });
                    final d = snapshot.data!;
                    return Column(
                      children: [
                        Text(
                          d.displayName,
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitle(context),
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                        SizedBox(height: Responsive.gapXs(context) * 1.5),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.gapMd(context),
                            vertical: Responsive.gapXs(context) * 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                          ),
                          child: Text(
                            'Seviye ${d.level}',
                            style: TextStyle(
                              fontSize: Responsive.fontSizeBodySmall(context),
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Text(
                        'Kullanıcı',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeTitle(context),
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                      SizedBox(height: Responsive.gapXs(context) * 1.5),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.gapMd(context),
                          vertical: Responsive.gapXs(context) * 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                        ),
                        child: Text(
                          'Seviye A2',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeBodySmall(context),
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: Responsive.gapSm(context)),
          FutureBuilder<int?>(
            future: AppPrefs.getMembershipJoinedAtMs(),
            builder: (context, snapshot) {
              final ms = snapshot.data;
              final label = ms == null
                  ? 'Üyelik tarihi: —'
                  : 'Üyelik Tarihi: ${formatMembershipDateTurkish(DateTime.fromMillisecondsSinceEpoch(ms))}';
              return Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.fontSizeCaption(context),
                  color: Colors.grey.shade600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.gapMd(context),
        horizontal: Responsive.gapMd(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, Icons.menu_book_outlined, '250', 'Kelime'),
            const VerticalDivider(thickness: 1, color: Colors.grey),
            _buildStatItem(context, Icons.trending_up, 'A2', 'Seviye'),
            const VerticalDivider(thickness: 1, color: Colors.grey),
            _buildStatItem(context, Icons.workspace_premium_outlined, '4', 'Rozet'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _primary, size: Responsive.iconSizeMedium(context)),
        SizedBox(height: Responsive.gapSm(context)),
        Text(
          value,
          style: TextStyle(
            fontSize: Responsive.fontSizeTitleSmall(context),
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        SizedBox(height: Responsive.gapXs(context) * 0.5),
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSizeCaption(context),
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Responsive.fontSizeTitleSmall(context),
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final radius = Responsive.cardRadius(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
            vertical: Responsive.gapMd(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.gapSm(context)),
                decoration: BoxDecoration(
                  color: _primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(Responsive.gapMd(context)),
                ),
                child: Icon(icon, color: _primary, size: Responsive.iconSizeMedium(context)),
              ),
              SizedBox(width: Responsive.gapMd(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Responsive.fontSizeBody(context),
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    SizedBox(height: Responsive.gapXs(context) * 0.5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: Responsive.fontSizeBodySmall(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade500,
                size: Responsive.iconSizeMedium(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final radius = Responsive.cardRadius(context);
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: () async {
            await AuthService.logout();
            if (!context.mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomePage()),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context) + Responsive.gapXs(context)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.red.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red.shade400,
                  size: Responsive.iconSizeMedium(context),
                ),
                SizedBox(width: Responsive.gapSm(context)),
                Text(
                  'Çıkış yap',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBody(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeAvatar(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final croppedPath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CropPhotoPage(imagePath: picked.path),
        ),
      );

      if (croppedPath == null) return;

      final sourceFile = File(croppedPath);
      if (!await sourceFile.exists()) return;
      await AuthService.updateAvatar(sourceFile.path);

    } catch (e, st) {
      debugPrint('Avatar seçme hatası: $e\n$st');
    }
  }
}
