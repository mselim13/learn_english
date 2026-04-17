import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _repeatController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRepeat = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_newController.text != _repeatController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni parolalar eşleşmiyor.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_newController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni parola en az 6 karakter olmalı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parola başarıyla güncellendi.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Şifre değiştir'),
            SizedBox(height: Responsive.gapLg(context)),
            _buildField(context, 'Mevcut parola', _currentController, _obscureCurrent, () => setState(() => _obscureCurrent = !_obscureCurrent)),
            SizedBox(height: Responsive.gapMd(context)),
            _buildField(context, 'Yeni parola', _newController, _obscureNew, () => setState(() => _obscureNew = !_obscureNew)),
            SizedBox(height: Responsive.gapMd(context)),
            _buildField(context, 'Yeni parola (tekrar)', _repeatController, _obscureRepeat, () => setState(() => _obscureRepeat = !_obscureRepeat)),
            SizedBox(height: Responsive.gapLg(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                  minimumSize: Size(0, Responsive.minTouchTarget(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  ),
                ),
                child: Text('Kaydet', style: TextStyle(fontSize: Responsive.fontSizeButton(context))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, TextEditingController c, bool obscure, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Responsive.fontSizeBodySmall(context),
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        SizedBox(height: Responsive.gapXs(context)),
        TextField(
          controller: c,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            suffixIcon: IconButton(
              onPressed: toggle,
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
