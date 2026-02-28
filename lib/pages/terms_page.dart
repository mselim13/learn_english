import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppTheme.buildAppBar(context, 'Kullanım koşulları'),
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
