import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'edit_profile_page.dart';
import 'notification_settings_page.dart';
import 'level_roadmap_page.dart';
import 'daily_goal_page.dart';
import 'badges_page.dart';
import 'help_faq_page.dart';
import 'translate_page.dart';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProfileCard(context),
              const SizedBox(height: 20),
              _buildStatsRow(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Hesap'),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.person_outline,
                title: 'Profil düzenle',
                subtitle: 'İsim, fotoğraf, seviye',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                context,
                icon: Icons.notifications_outlined,
                title: 'Bildirimler',
                subtitle: 'Hatırlatmalar ve bildirimler',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage())),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Öğrenme'),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.translate_outlined,
                title: 'Çeviri / Sözlük',
                subtitle: 'Kelime veya ifade çevir',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslatePage())),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                context,
                icon: Icons.map_outlined,
                title: 'Seviye yol haritası',
                subtitle: 'A1\'den C2\'ye ilerleme',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelRoadmapPage())),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                context,
                icon: Icons.flag_outlined,
                title: 'Günlük hedef',
                subtitle: 'Hedef süre ve ilerleme',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyGoalPage())),
              ),
              const SizedBox(height: 10),
              _buildOptionCard(
                context,
                icon: Icons.workspace_premium_outlined,
                title: 'Rozetler',
                subtitle: 'Kazandığın başarılar',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesPage())),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Uygulama'),
              const SizedBox(height: 12),
              _buildOptionCard(
                context,
                icon: Icons.help_outline,
                title: 'Yardım ve destek',
                subtitle: 'SSS, iletişim',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpFaqPage())),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 28),
              _buildLogoutButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profilim',
          style: TextStyle(
            fontSize: 24,
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
          icon: const Icon(Icons.settings_outlined, color: _primary, size: 26),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: _primaryLight,
                child: Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 52),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nihan Karaca',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _primary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Seviye A2',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Üyelik Tarihi: Kasım 2024',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
            _buildStatItem(Icons.menu_book_outlined, '250', 'Kelime'),
            const VerticalDivider(thickness: 1, color: Colors.grey),
            _buildStatItem(Icons.trending_up, 'A2', 'Seviye'),
            const VerticalDivider(thickness: 1, color: Colors.grey),
            _buildStatItem(Icons.workspace_premium_outlined, '4', 'Rozet'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                Icon(Icons.logout, color: Colors.red.shade400, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Çıkış yap',
                  style: TextStyle(
                    fontSize: 16,
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
}
