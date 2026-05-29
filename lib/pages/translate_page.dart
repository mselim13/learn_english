import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../services/gemini_service.dart';
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

  // Yerel sözlük (offline öneriler için)
  Map<String, String> _dict = const {};
  List<MapEntry<String, String>> _matches = const [];

  // Gemini sonucu
  bool _loading = false;
  Map<String, String?>? _geminiResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDict();
    _inputController.addListener(_updateMatches);
  }

  Future<void> _loadDict() async {
    try {
      final raw = await rootBundle
          .loadString('assets/dictionaries/en_tr_basic.json');
      final data = (jsonDecode(raw) as Map)
          .map((k, v) => MapEntry(k.toString(), v.toString()));
      if (!mounted) return;
      setState(() => _dict = data);
      _updateMatches();
    } catch (_) {}
  }

  void _updateMatches() {
    final q = _inputController.text.trim().toLowerCase();
    if (q.isEmpty || _dict.isEmpty) {
      if (_matches.isNotEmpty) setState(() => _matches = const []);
      return;
    }
    final out = <MapEntry<String, String>>[];
    for (final e in _dict.entries) {
      if (e.key.startsWith(q)) out.add(MapEntry(e.key, e.value));
      if (out.length >= 8) break;
    }
    setState(() => _matches = out);
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _geminiResult = null;
      _errorMessage = null;
    });

    final result = await GeminiService.translate(text);

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result != null) {
        _geminiResult = result;
      } else {
        // Gemini'ye ulaşılamadı — yerel sözlüğe bak
        final local = _dict[text.toLowerCase()];
        if (local != null) {
          _geminiResult = {
            'translation': local,
            'partOfSpeech': null,
            'example': null,
            'exampleTr': null,
          };
        } else {
          _errorMessage = 'Çeviri yapılamadı. İnternet bağlantınızı kontrol edin.';
        }
      }
    });
  }

  Future<void> _addToVocab(
      String word, String meaning, {
      String example = '',
      String exampleTr = '',
    }) async {
    await VocabularyBookService.addWord(
      word: word,
      meaning: meaning,
      example: example,
      exampleTr: exampleTr,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kelime defterine eklendi'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

            // Gemini badge
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 13, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Gemini AI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'İngilizce → Türkçe',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBodySmall(context),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.gapMd(context)),

            // Giriş alanı
            TextField(
              controller: _inputController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Kelime veya cümle yaz (İngilizce)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Responsive.cardRadius(context)),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                suffixIcon: _inputController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _inputController.clear();
                          setState(() {
                            _geminiResult = null;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
            SizedBox(height: Responsive.gapMd(context)),

            // Çevir butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _translate,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.translate),
                label: Text(_loading ? 'Çevriliyor...' : 'Çevir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      vertical: Responsive.buttonPaddingVertical(context)),
                  minimumSize:
                      Size(0, Responsive.minTouchTarget(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Responsive.cardRadius(context)),
                  ),
                ),
              ),
            ),

            // Hata mesajı
            if (_errorMessage != null) ...[
              SizedBox(height: Responsive.gapMd(context)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(Responsive.cardRadius(context)),
                  border:
                      Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                ),
              ),
            ],

            // Gemini sonucu
            if (_geminiResult != null) ...[
              SizedBox(height: Responsive.gapLg(context)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(Responsive.cardRadius(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Çeviri + kelime türü
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_geminiResult!['partOfSpeech'] != null)
                                Text(
                                  _geminiResult!['partOfSpeech']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              Text(
                                _geminiResult!['translation'] ?? '-',
                                style: TextStyle(
                                  fontSize:
                                      Responsive.fontSizeTitleSmall(context),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Kelime defterine ekle
                        IconButton(
                          tooltip: 'Kelime defterine ekle',
                          icon: const Icon(Icons.add_circle_outline,
                              color: AppTheme.primary),
                          onPressed: () => _addToVocab(
                            _inputController.text.trim(),
                            _geminiResult!['translation'] ?? '',
                            example: _geminiResult!['example'] ?? '',
                            exampleTr: _geminiResult!['exampleTr'] ?? '',
                          ),
                        ),
                      ],
                    ),

                    // Örnek cümle
                    if (_geminiResult!['example'] != null) ...[
                      Divider(height: Responsive.gapLg(context)),
                      Text(
                        'Örnek Cümle',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _geminiResult!['example']!,
                        style: TextStyle(
                          fontSize: Responsive.fontSizeBody(context),
                          color: Colors.grey.shade800,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (_geminiResult!['exampleTr'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _geminiResult!['exampleTr']!,
                          style: TextStyle(
                            fontSize: Responsive.fontSizeBodySmall(context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],

            // Yerel sözlük önerileri (offline)
            if (_matches.isNotEmpty) ...[
              SizedBox(height: Responsive.gapLg(context)),
              Text(
                'Sözlük Önerileri',
                style: TextStyle(
                  fontSize: Responsive.fontSizeCaption(context),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: Responsive.gapSm(context)),
              ..._matches.map((e) => _DictRow(
                    en: e.key,
                    tr: e.value,
                    onAdd: () => _addToVocab(e.key, e.value),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _DictRow extends StatelessWidget {
  const _DictRow(
      {required this.en, required this.tr, required this.onAdd});
  final String en;
  final String tr;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.gapXs(context)),
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(Responsive.cardRadius(context)),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(Responsive.cardRadius(context)),
          onTap: () {},
          child: Padding(
            padding:
                EdgeInsets.all(Responsive.cardPadding(context) * 0.75),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(en,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      Text(tr,
                          style: TextStyle(
                              color: Colors.grey.shade700)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Kelime defterine ekle',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
