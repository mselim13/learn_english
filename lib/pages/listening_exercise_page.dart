import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/app_prefs.dart';
import '../services/study_session_tracker.dart';
import '../services/stats_store.dart';
import '../services/gemini_service.dart';

const _fallbackSentences = [
  'Hello, how are you today?',
  'Thank you for your help.',
  'I am learning English every day.',
];

class ListeningExercisePage extends StatefulWidget {
  const ListeningExercisePage({super.key});

  @override
  State<ListeningExercisePage> createState() => _ListeningExercisePageState();
}

class _ListeningExercisePageState extends State<ListeningExercisePage> {
  // ── Yükleme ──────────────────────────────────────────────────────
  bool _loading = true;
  bool _aiGenerated = false;

  // ── TTS ───────────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  bool _playing = false;

  // ── Cümleler ──────────────────────────────────────────────────────
  List<String> _sentences = const [];
  int _currentIndex = 0;
  bool _showText = false;

  // ── Kullanıcı girişleri ───────────────────────────────────────────
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(activity: LearningActivity.listening);
    _initTts();
    _loadSentences();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts.setErrorHandler((msg) {
      if (mounted) setState(() => _playing = false);
    });
  }

  Future<void> _loadSentences() async {
    setState(() => _loading = true);

    final level = await AppPrefs.getUserLevel();
    final aiSentences = await GeminiService.generateListeningSentences(
      level: level,
      count: 3,
    );

    if (!mounted) return;

    final sentences = (aiSentences != null && aiSentences.isNotEmpty)
        ? aiSentences
        : List<String>.from(_fallbackSentences);

    // Önceki controller/focusnode'ları temizle
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _controllers.clear();
    _focusNodes.clear();

    for (var i = 0; i < sentences.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    setState(() {
      _sentences = sentences;
      _aiGenerated = aiSentences != null && aiSentences.isNotEmpty;
      _loading = false;
      _currentIndex = 0;
      _showText = false;
    });
  }

  Future<void> _speak() async {
    if (_playing) {
      await _tts.stop();
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    await _tts.speak(_sentences[_currentIndex]);
  }

  /// Normalizes a sentence for comparison: lowercase, strip punctuation, trim.
  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9\s']"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Word-level similarity: fraction of reference words found in user text.
  double _similarity(String reference, String userAnswer) {
    if (userAnswer.trim().isEmpty) return 0.0;
    final refWords = _normalize(reference).split(' ');
    final ansWords = _normalize(userAnswer).split(' ').toSet();
    if (refWords.isEmpty) return 0.0;
    final matches = refWords.where((w) => ansWords.contains(w)).length;
    return matches / refWords.length;
  }

  Future<void> _finish() async {
    // Stop TTS if playing
    if (_playing) {
      await _tts.stop();
      setState(() => _playing = false);
    }

    int correctCount = 0;
    final results = <Map<String, dynamic>>[];

    for (var i = 0; i < _sentences.length; i++) {
      final sim = _similarity(_sentences[i], _controllers[i].text);
      final isCorrect = sim >= 0.75; // 75% word match = correct
      if (isCorrect) correctCount++;
      results.add({
        'sentence': _sentences[i],
        'answer': _controllers[i].text,
        'sim': sim,
        'correct': isCorrect,
      });
    }

    final score = ((correctCount / _sentences.length) * 100).round();

    // Stats'a kaydet
    await StatsStore.bumpSkill(LearningActivity.listening, minutes: correctCount);
    await StatsStore.recomputeBadges();

    if (!mounted) return;
    _showResult(score: score, correctCount: correctCount, results: results);
  }

  void _showResult({
    required int score,
    required int correctCount,
    required List<Map<String, dynamic>> results,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('Dinleme sonucu '),
            Text(score >= 80 ? '🎉' : score >= 50 ? '👍' : '💪'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correctCount / ${_sentences.length} doğru',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text('%$score başarı',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: correctCount / _sentences.length,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score >= 80 ? Colors.green : score >= 50 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Her cümle için detay
              ...results.map((r) {
                final correct = r['correct'] as bool;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: correct ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: correct ? Colors.green.shade200 : Colors.red.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              correct ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: correct ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                r['sentence'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: correct ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if ((r['answer'] as String).isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Senin cevabın: ${r['answer']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              if (_aiGenerated) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Gemini AI tarafından oluşturuldu',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadSentences();
            },
            child: const Text('Tekrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    StudySessionTracker.stop();
    _tts.stop();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final spacing = Responsive.spacing(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: _loading ? _buildLoading(context, spacing) : _buildExercise(context, spacing),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTheme.buildAppBar(context, 'Dinleme'),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primary),
                SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Gemini AI cümleler hazırlıyor...',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercise(BuildContext context, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTheme.buildAppBar(context, 'Dinleme'),
        SizedBox(height: spacing * 0.5),

        // Kaydırılabilir içerik (klavye açılınca taşmayı önler)
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI badge
                if (_aiGenerated)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 13, color: AppTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Gemini AI • Seviyene göre hazırlandı',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                // Progress
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _sentences.length,
                  backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
                SizedBox(height: spacing * 0.5),
                Text(
                  '${_currentIndex + 1} / ${_sentences.length}',
                  style: TextStyle(fontSize: Responsive.fontSizeCaption(context), color: Colors.grey.shade600),
                ),
                SizedBox(height: spacing),

                Text(
                  'Cümleyi dinle ve dinlediklerini yaz:',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBodySmall(context),
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: spacing),

                // Cümle kartı
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  decoration: AppTheme.cardDecorationFor(context),
                  child: Column(
                    children: [
                      Icon(
                        Icons.headphones,
                        size: Responsive.iconSizeLarge(context),
                        color: AppTheme.primary.withValues(alpha: 0.8),
                      ),
                      SizedBox(height: spacing),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _showText
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Text(
                          '••••••••••••••••••••',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitle(context),
                            letterSpacing: 4,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        secondChild: Text(
                          _sentences[_currentIndex],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitleSmall(context),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing * 2),

                // Play button
                Center(
                  child: IconButton.filled(
                    onPressed: _speak,
                    icon: Icon(
                      _playing ? Icons.stop : Icons.play_arrow,
                      size: Responsive.iconSizeLarge(context) * 0.6,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _playing ? Colors.red : AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.7),
                      minimumSize: Size(
                        Responsive.minTouchTarget(context) * 2,
                        Responsive.minTouchTarget(context) * 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                // Kullanıcı girişi
                Text(
                  'Dinlediklerini yaz:',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBody(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Responsive.cardPadding(context)),
                  decoration: AppTheme.cardDecorationFor(context),
                  child: TextField(
                    controller: _controllers[_currentIndex],
                    focusNode: _focusNodes[_currentIndex],
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Dinlediğin cümleyi buraya yaz...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: Responsive.fontSizeBody(context)),
                  ),
                ),
                SizedBox(height: spacing * 0.5),

                // Metni göster/gizle
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showText = !_showText),
                    icon: Icon(
                      _showText ? Icons.visibility_off : Icons.visibility,
                      size: Responsive.iconSizeSmall(context),
                    ),
                    label: Text(
                      _showText ? 'Metni gizle' : 'Metni göster (ipucu)',
                      style: TextStyle(fontSize: Responsive.fontSizeButton(context)),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                      minimumSize: Size(0, Responsive.minTouchTarget(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 2),
              ],
            ),
          ),
        ),

        // İleri / Bitir navigasyonu (klavyeden bağımsız, hep altta)
        Padding(
          padding: EdgeInsets.only(top: spacing * 0.5),
          child: Row(
            children: [
              // Geri
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _currentIndex--;
                      _showText = false;
                    }),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: AppTheme.primary),
                      padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                      minimumSize: Size(0, Responsive.minTouchTarget(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                      ),
                    ),
                    child: const Text('Geri'),
                  ),
                ),
              if (_currentIndex > 0) SizedBox(width: spacing),
              // İleri / Bitir
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _currentIndex < _sentences.length - 1
                      ? () => setState(() {
                            _currentIndex++;
                            _showText = false;
                          })
                      : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                    minimumSize: Size(0, Responsive.minTouchTarget(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                    ),
                  ),
                  child: Text(_currentIndex < _sentences.length - 1 ? 'İleri' : 'Bitir'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
