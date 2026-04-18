import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/vocabulary_book_service.dart';
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
  Map<String, String> _dict = const {};
  List<MapEntry<String, String>> _matches = const [];

  @override
  void initState() {
    super.initState();
    _loadDict();
    _inputController.addListener(_updateMatches);
  }

  Future<void> _loadDict() async {
    try {
      final raw = await rootBundle.loadString('assets/dictionaries/en_tr_basic.json');
      final data = (jsonDecode(raw) as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
      if (!mounted) return;
      setState(() => _dict = data);
      _updateMatches();
    } catch (_) {
      // keep empty; UI will show fallback
    }
  }

  void _updateMatches() {
    final q = _inputController.text.trim().toLowerCase();
    if (q.isEmpty || _dict.isEmpty) {
      if (_matches.isNotEmpty) setState(() => _matches = const []);
      return;
    }
    final out = <MapEntry<String, String>>[];
    for (final e in _dict.entries) {
      if (e.key.contains(q)) out.add(MapEntry(e.key, e.value));
      if (out.length >= 12) break;
    }
    setState(() => _matches = out);
  }

  void _translate() {
    final text = _inputController.text.trim().toLowerCase();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final r = _dict.isEmpty ? null : _dict[text];
      setState(() {
        _loading = false;
        _result = r ?? 'Çeviri bulunamadı. (Örnek: hello, thank you, welcome)';
      });
    });
  }

  @override
  void dispose() {
    _inputController.removeListener(_updateMatches);
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
            if (_matches.isNotEmpty) ...[
              SizedBox(height: Responsive.gapMd(context)),
              Text(
                'Sözlük',
                style: TextStyle(
                  fontSize: Responsive.fontSizeCaption(context),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              ..._matches.map((e) => _DictRow(
                    en: e.key,
                    tr: e.value,
                    onAdd: () async {
                      await VocabularyBookService.addWord(word: e.key, meaning: e.value);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kelime defterine eklendi'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  )),
            ],
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

class _DictRow extends StatelessWidget {
  const _DictRow({required this.en, required this.tr, required this.onAdd});
  final String en;
  final String tr;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.gapXs(context)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.75),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(en, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(tr, style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Kelime defterine ekle',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
