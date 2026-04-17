import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const String _text = '''
Gizlilik Politikası

Son güncelleme: 2024

1. Toplanan veriler
Uygulama kullanımı sırasında hesap bilgileriniz, öğrenme ilerlemeniz ve cihaz bilgileri toplanabilir.

2. Veri kullanımı
Verileriniz yalnızca hizmeti iyileştirmek, kişiselleştirmek ve size öneriler sunmak için kullanılır.

3. Veri paylaşımı
Kişisel verileriniz üçüncü taraflarla satılmaz. Yasal zorunluluklar dışında paylaşılmaz.

4. Güvenlik
Verileriniz şifreli ve güvenli sunucularda saklanır.

5. Haklarınız
Verilerinize erişim, düzeltme veya silme talebinde bulunabilirsiniz.

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
