import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  static final List<Map<String, String>> _faq = [
    {'q': 'Hesabımı nasıl oluştururum?', 'a': 'Giriş ekranından "Kayıt ol" ile e-posta ve şifre ile hesap oluşturabilirsiniz.'},
    {'q': 'Şifremi unuttum, ne yapmalıyım?', 'a': 'Giriş ekranında "Parolanı mı unuttun?" linkine tıklayıp e-posta ile sıfırlama talimatı alabilirsiniz.'},
    {'q': 'Günlük hedefi nasıl değiştiririm?', 'a': 'Profil > Günlük hedef sayfasından hedef süreyi dakika olarak ayarlayabilirsiniz.'},
    {'q': 'Rozetler nasıl kazanılır?', 'a': 'Belirli görevleri tamamlayarak (ör. 7 gün streak, 50 kelime) rozetlerin kilidi açılır.'},
    {'q': 'Kelime defterine nasıl kelime eklerim?', 'a': 'Kelime detay sayfasında "Öğrendim" veya yıldız ikonuna basarak kelimeyi deftere ekleyebilirsiniz.'},
    {'q': 'Seviyem nasıl yükselir?', 'a': 'Dersleri tamamlayıp quiz’lerden yeterli puan alarak bir sonraki seviyeye geçersiniz.'},
    {'q': 'Bildirimleri kapatabilir miyim?', 'a': 'Profil > Bildirimler veya Ayarlar > Bildirimler bölümünden bildirimleri açıp kapatabilirsiniz.'},
    {'q': 'Uygulama hangi dilleri destekliyor?', 'a': 'Arayüz Türkçe dilini desteklemektedir.'},
    {'q': 'Verilerim güvende mi?', 'a': 'Evet. Gizlilik politikamızda detayları inceleyebilirsiniz. Verileriniz şifreli saklanır.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppTheme.buildAppBar(context, 'Yardım ve SSS'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ...List.generate(_faq.length, (i) {
                    final item = _faq[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['q']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['a']!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İletişim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sorunuz mu var? Bize ulaşın.',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 20, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            const Text('support@learnenglish.app', style: TextStyle(fontSize: 14, color: AppTheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
