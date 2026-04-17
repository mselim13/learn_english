import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFF4A148C),
                    size: Responsive.iconSizeSmall(context),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: Responsive.minTouchTarget(context),
                    minHeight: Responsive.minTouchTarget(context),
                  ),
                ),
                SizedBox(width: Responsive.gapSm(context)),
              ],
            ),
            SizedBox(height: Responsive.gapSm(context)),
            Text(
              'Parolayı sıfırla',
              style: TextStyle(
                fontSize: Responsive.fontSizeTitle(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            Text(
              'E-posta adresini gir. Sıfırlama linkini oraya göndereceğiz.',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@email.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sıfırlama linki e-posta adresine gönderildi.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A3EC8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                  minimumSize: Size(0, Responsive.minTouchTarget(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  ),
                ),
                child: Text(
                  'Gönder',
                  style: TextStyle(fontSize: Responsive.fontSizeButton(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
