import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppTheme.buildAppBar(context, 'Gizlilik politikası'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration,
                  child: Text(
                    _text,
                    style: TextStyle(
                      fontSize: 15,
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
