import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import 'about_page.dart';
import 'terms_page.dart';
import 'privacy_policy_page.dart';
import 'change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _primary = Color(0xFF4A148C);
  static const Color _primaryLight = Color(0xFFD1BEEB);
  static const Color _surface = Color(0xFFF5F0FA);

  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gapSm = Responsive.gapSm(context);
    final gapLg = Responsive.gapLg(context);
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
              SizedBox(height: gapLg),
              _buildSectionTitle('Hesap ve gizlilik'),
              SizedBox(height: gapSm),
              _buildOptionCard(
                context,
                icon: Icons.lock_outline,
                title: 'Şifre değiştir',
                subtitle: 'Hesap güvenliği',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage())),
              ),
              SizedBox(height: gapSm),
              _buildOptionCard(
                context,
                icon: Icons.security,
                title: 'Gizlilik ayarları',
                subtitle: 'Veri paylaşımı, reklamlar',
                onTap: () {},
              ),
              SizedBox(height: gapSm),
              _buildOptionCard(
                context,
                icon: Icons.storage_outlined,
                title: 'Önbellek ve veri',
                subtitle: 'Önbelleği temizle',
                onTap: () => _showClearCacheDialog(context),
              ),
              SizedBox(height: gapLg),
              _buildSectionTitle('Ses ve medya'),
              SizedBox(height: gapSm),
              _buildSwitchCard(
                icon: Icons.volume_up_outlined,
                title: 'Ses efektleri',
                subtitle: 'Doğru/yanlış sesleri',
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              SizedBox(height: gapLg),
              _buildSectionTitle('Hakkında'),
              SizedBox(height: gapSm),
              _buildOptionCard(
                context,
                icon: Icons.info_outline,
                title: 'Uygulama sürümü',
                subtitle: '1.0.0 (Build 1)',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage())),
              ),
              SizedBox(height: gapSm),
              _buildOptionCard(
                context,
                icon: Icons.description_outlined,
                title: 'Kullanım koşulları',
                subtitle: 'Şartlar ve koşullar',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage())),
              ),
              SizedBox(height: gapSm),
              _buildOptionCard(
                context,
                icon: Icons.privacy_tip_outlined,
                title: 'Gizlilik politikası',
                subtitle: 'Veri kullanımı',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
              ),
              SizedBox(height: Responsive.gapXl(context)),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: Icon(Icons.delete_forever_outlined, color: Colors.red, size: Responsive.iconSizeSmall(context)),
                  label: Text(
                    'Hesabı sil',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBody(context),
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                    minimumSize: Size(0, Responsive.minTouchTarget(context)),
                  ),
                ),
              ),
              SizedBox(height: gapLg),
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
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_new, color: _primary, size: Responsive.iconSizeSmall(context)),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: Responsive.minTouchTarget(context),
            minHeight: Responsive.minTouchTarget(context),
          ),
        ),
        SizedBox(width: Responsive.gapSm(context)),
        Text(
          'Ayarlar',
          style: TextStyle(
            fontSize: Responsive.fontSizeTitle(context),
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Responsive.fontSizeBody(context),
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSwitchCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.cardPadding(context),
        vertical: Responsive.buttonPaddingVertical(context),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.gapSm(context)),
            decoration: BoxDecoration(
              color: _primaryLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(Responsive.cardRadius(context) * 0.8),
            ),
            child: Icon(icon, color: _primary, size: Responsive.iconSizeSmall(context)),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _primary,
          ),
        ],
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
      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.cardPadding(context),
            vertical: Responsive.buttonPaddingVertical(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
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
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context) * 0.8),
                ),
                child: Icon(icon, color: _primary, size: Responsive.iconSizeSmall(context)),
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
              Icon(Icons.chevron_right, color: Colors.grey.shade500, size: Responsive.iconSizeSmall(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Önbelleği temizle?'),
        content: const Text(
          'Önbellek temizlendiğinde uygulama biraz daha yavaş açılabilir. Devam etmek istiyor musun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Önbellek temizlendi'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Temizle', style: TextStyle(color: _primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Emin misiniz?'),
        content: const Text(
          'Hesabınız kalıcı olarak silinecektir. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Hesap silme işlemi ileride eklenecek
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
