import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

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
    final gapSm = Responsive.gapSm(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        scroll: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Yardım ve SSS'),
            SizedBox(height: Responsive.gapMd(context)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...List.generate(_faq.length, (i) {
                    final item = _faq[i];
                    return Padding(
                      padding: EdgeInsets.only(bottom: gapSm),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.cardPadding(context)),
                        decoration: AppTheme.cardDecorationFor(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['q']!,
                              style: TextStyle(
                                fontSize: Responsive.fontSizeBody(context),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            SizedBox(height: gapSm),
                            Text(
                              item['a']!,
                              style: TextStyle(
                                fontSize: Responsive.fontSizeBodySmall(context),
                                height: 1.5,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: gapSm),
                  Container(
                    padding: EdgeInsets.all(Responsive.cardPadding(context)),
                    decoration: AppTheme.cardDecorationFor(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İletişim',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeBody(context),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        SizedBox(height: gapSm),
                        Text(
                          'Sorunuz mu var? Bize ulaşın.',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeBodySmall(context),
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: gapSm),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: Responsive.iconSizeSmall(context),
                              color: AppTheme.primary,
                            ),
                            SizedBox(width: Responsive.gapSm(context)),
                            const Expanded(
                              child: Text(
                                'support@learnenglish.app',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.gapLg(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
