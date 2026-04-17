import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  final _inputController = TextEditingController();
  String? _result;
  bool _loading = false;

  static const Map<String, String> _mockDict = {
    'hello': 'Merhaba',
    'thank you': 'Teşekkürler',
    'goodbye': 'Hoşça kal',
    'please': 'Lütfen',
    'yes': 'Evet',
    'no': 'Hayır',
    'water': 'Su',
    'food': 'Yemek',
    'friend': 'Arkadaş',
    'family': 'Aile',
    'how are you': 'Nasılsın?',
    'good morning': 'Günaydın',
    'good night': 'İyi geceler',
  };

  void _translate() {
    final text = _inputController.text.trim().toLowerCase();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _result = _mockDict[text] ?? 'Çeviri bulunamadı. (Örnek: hello, thank you, goodbye)';
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Çeviri / Sözlük'),
            SizedBox(height: Responsive.gapSm(context)),
            Text(
              'Kelime veya kısa ifade yaz (İngilizce → Türkçe)',
              style: TextStyle(fontSize: Responsive.fontSizeBodySmall(context), color: Colors.grey.shade700),
            ),
            SizedBox(height: Responsive.gapMd(context)),
            TextField(
              controller: _inputController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Örn: hello, thank you, good morning',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapMd(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _translate,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate),
                label: Text(_loading ? 'Aranıyor...' : 'Çevir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                  minimumSize: Size(0, Responsive.minTouchTarget(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  ),
                ),
              ),
            ),
            if (_result != null) ...[
              SizedBox(height: Responsive.gapLg(context)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                decoration: AppTheme.cardDecorationFor(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sonuç',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeCaption(context),
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: Responsive.gapSm(context)),
                    Text(
                      _result!,
                      style: TextStyle(
                        fontSize: Responsive.fontSizeTitleSmall(context),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
