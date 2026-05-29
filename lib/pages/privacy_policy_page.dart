import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _text = '''
Gizlilik Politikası

Son güncelleme: 2026

1. Toplanan veriler
Profil bilgileriniz (ad, e-posta), öğrenme ilerlemeniz, uygulama tercihleri ve cihazınızda üretilen kullanım verileri uygulama tarafından işlenebilir.

2. Veri kullanımı
Verileriniz yalnızca uygulama özelliklerini sunmak (istatistik, hatırlatma, kişiselleştirme) için kullanılır.

3. Veri paylaşımı
Bu sürümde verileriniz uygulama içinde yerel olarak tutulur; kişisel verileriniz üçüncü taraflara satılmaz. İleride isteğe bağlı bulut veya analiz hizmetleri eklenirse bu metin güncellenir.

4. Saklama ve güvenlik
Öğrenme verileriniz ve hesap bilgileriniz öncelikle cihazınızda (yerel) saklanır. Cihaz güvenliği ve ekran kilidi sizin sorumluluğunuzdadır.

5. Haklarınız
Ayarlar üzerinden hesabınızı sildiğinizde yerel veriler silinir. Erişim ve düzeltme talepleri için iletişim adresini kullanabilirsiniz.

İletişim: privacy@learnenglish.app
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        scroll: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Gizlilik politikası'),
            SizedBox(height: Responsive.gapMd(context)),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  decoration: AppTheme.cardDecorationFor(context),
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBody(context),
                      height: 1.7,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
