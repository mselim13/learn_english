import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Lütfen e-posta adresinizi girin.');
      return;
    }
    if (!email.contains('@')) {
      _showError('Geçerli bir e-posta adresi girin.');
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.forgotPassword(email);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      _showError(result.error ?? 'Bir hata oluştu.');
      return;
    }

    // Başarılı — OTP sayfasına geç, email'i taşı
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(email: email),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: Responsive.gapSm(context)),
            const Icon(Icons.lock_reset, size: 48, color: Color(0xFF7A3EC8)),
            SizedBox(height: Responsive.gapMd(context)),
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
              'Hesabına kayıtlı e-posta adresini gir. 6 haneli sıfırlama kodu gönderelim.',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              enabled: !_loading,
              decoration: InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A3EC8),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: Responsive.buttonPaddingVertical(context)),
                  minimumSize: Size(0, Responsive.minTouchTarget(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Responsive.cardRadius(context)),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Kod Gönder',
                        style:
                            TextStyle(fontSize: Responsive.fontSizeButton(context)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
