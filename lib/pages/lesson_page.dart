import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key, this.title = 'Ders', this.steps});
  final String title;
  final List<String>? steps;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _step = 0;
  late List<String> _steps;

  @override
  void initState() {
    super.initState();
    _steps = widget.steps ?? [
      'İngilizce\'de selamlaşma için "Hello" ve "Hi" kullanılır. Günün saatine göre "Good morning" (sabah), "Good afternoon" (öğleden sonra), "Good evening" (akşam) da kullanabilirsin.',
      '"How are you?" = "Nasılsın?" demektir. Sık kullanılan cevaplar: "I\'m fine, thank you." (İyiyim, teşekkürler), "Not bad." (Fena değil), "I\'m great!" (Harikayım).',
      'Resmi ortamlarda "Good morning" veya "Good afternoon" tercih edilir. Arkadaşlar arasında "Hi" veya "Hey" yeterlidir.',
      '"Nice to meet you" = "Tanıştığımıza memnun oldum". Cevap: "Nice to meet you too." (Ben de.).',
      'Veda için: "Goodbye", "Bye", "See you" (Görüşürüz), "Take care" (Kendine iyi bak).',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.horizontalPadding(context);
    final contentPadding = Responsive.cardPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildAppBar(context, widget.title, showBack: false),
              SizedBox(height: Responsive.gapLg(context)),
              LinearProgressIndicator(
                value: (_step + 1) / _steps.length,
                backgroundColor: AppTheme.primaryLight.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              Text(
                'Adım ${_step + 1} / ${_steps.length}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              SizedBox(height: Responsive.gapXl(context)),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(contentPadding),
                  decoration: AppTheme.cardDecoration,
                  child: SingleChildScrollView(
                    child: Text(
                      _steps[_step],
                      style: TextStyle(
                        fontSize: Responsive.fontSizeBody(context),
                        height: 1.6,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: Responsive.gapMd(context)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_step < _steps.length - 1) {
                      setState(() => _step++);
                    } else {
                      setState(() => _step = 0);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.buttonPaddingVertical(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_step < _steps.length - 1 ? 'İleri' : 'Bitir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
