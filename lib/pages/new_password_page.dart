import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import 'login_page.dart';

/// Sayfa 2 — Yeni parolayı belirle
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({
    super.key,
    required this.email,
    required this.otp,
  });
  final String email;
  final String otp;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPw = _newPasswordController.text;

    if (newPw.length < 6) {
      _showError('Yeni parola en az 6 karakter olmalıdır.');
      return;
    }
    if (newPw != _confirmPasswordController.text) {
      _showError('Parolalar eşleşmiyor.');
      return;
    }

    setState(() => _loading = true);
    final result = await AuthService.resetPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: newPw,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      _showError(result.error ?? 'Bir hata oluştu.');
      return;
    }

    _showSuccess();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Parola Sıfırlandı ✅'),
        content: const Text(
            'Parolanız başarıyla güncellendi. Yeni parolanızla giriş yapabilirsiniz.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A3EC8)),
            child: const Text('Giriş Yap',
                style: TextStyle(color: Colors.white)),
          ),
        ],
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
            const Icon(Icons.lock_reset, size: 48, color: Color(0xFF7A3EC8)),
            SizedBox(height: Responsive.gapMd(context)),
            Text(
              'Yeni parola',
              style: TextStyle(
                fontSize: Responsive.fontSizeTitle(context),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A148C),
              ),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            Text(
              'Hesabın için yeni bir parola belirle.',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            SizedBox(height: Responsive.gapLg(context)),

            // Yeni parola
            Text(
              'Yeni Parola',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.gapXs(context)),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'En az 6 karakter',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Responsive.cardRadius(context)),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapMd(context)),

            // Parola tekrar
            Text(
              'Parola Tekrar',
              style: TextStyle(
                fontSize: Responsive.fontSizeBody(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.gapXs(context)),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'Aynı parolayı tekrar gir',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Responsive.cardRadius(context)),
                ),
              ),
            ),

            SizedBox(height: Responsive.gapLg(context)),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
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
                        'Parolayı Sıfırla',
                        style: TextStyle(
                            fontSize: Responsive.fontSizeButton(context)),
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
