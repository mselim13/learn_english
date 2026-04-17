import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  static const String _text = '''
Kullanım Koşulları

Son güncelleme: 2024

1. Hizmetin kullanımı
Learn English uygulamasını yalnızca yasal ve uygun şekilde kullanmayı kabul edersiniz.

2. Hesap sorumluluğu
Hesap bilgilerinizin güvenliğinden siz sorumlusunuz.

3. Fikri mülkiyet
Uygulama içeriği ve telif hakları bize aittir. İzinsiz kopyalama yasaktır.

4. Sınırlama
Uygulama "olduğu gibi" sunulmaktadır. Belirli bir amaç için uygunluk garantisi verilmez.

5. Değişiklikler
Bu koşullar önceden bildirilerek güncellenebilir.

İletişim: support@learnenglish.app
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
            AppTheme.buildAppBar(context, 'Kullanım koşulları'),
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
