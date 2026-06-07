import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import 'new_password_page.dart';

/// Sayfa 1 — 6 haneli OTP kodunu gir
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});
  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resending = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _resend() async {
    setState(() => _resending = true);
    await AuthService.forgotPassword(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni kod gönderildi.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _next() {
    if (_otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen 6 haneli kodu eksiksiz girin.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NewPasswordPage(email: widget.email, otp: _otp),
      ),
    );
  }

  Widget _buildBox(int index) {
    return SizedBox(
      width: 44,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: !_loading,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A148C),
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7A3EC8), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
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
            const Icon(Icons.mark_email_read_outlined,
                size: 48, color: Color(0xFF7A3EC8)),
            SizedBox(height: Responsive.gapMd(context)),
            Text(
              'Kodu gir',
              style: TextStyle(
                fontSize: Responsive.fontSizeTitle(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: Responsive.fontSizeBody(context),
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: '6 haneli kod şu adrese gönderildi:\n'),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),

            // OTP kutular
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _buildBox),
            ),
            SizedBox(height: Responsive.gapMd(context)),

            // Yeniden gönder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kodu almadın mı? ',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBodySmall(context),
                    color: Colors.grey.shade600,
                  ),
                ),
                GestureDetector(
                  onTap: _resending ? null : _resend,
                  child: Text(
                    _resending ? 'Gönderiliyor...' : 'Tekrar gönder',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBodySmall(context),
                      color: const Color(0xFF7A3EC8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.gapLg(context)),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _next,
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
                child: Text(
                  'Devam Et',
                  style: TextStyle(fontSize: Responsive.fontSizeButton(context)),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapMd(context)),
          ],
        ),
      ),
    );
  }
}
