import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/app_prefs.dart';
import '../services/stats_store.dart';
import '../services/study_session_tracker.dart';
import '../services/gemini_service.dart';

// Yedek sabit sorular — Gemini'ye ulaşılamazsa kullanılır
const _fallbackQuestions = <Map<String, dynamic>>[
  {'word': 'Hello',      'options': ['Merhaba', 'Hoşça kal', 'Teşekkürler', 'Evet'],     'correct': 0},
  {'word': 'Thank you',  'options': ['Özür dilerim', 'Teşekkürler', 'Lütfen', 'Hayır'],  'correct': 1},
  {'word': 'Goodbye',    'options': ['Merhaba', 'Evet', 'Hoşça kal', 'Lütfen'],          'correct': 2},
  {'word': 'Please',     'options': ['Teşekkürler', 'Lütfen', 'Özür dilerim', 'Evet'],   'correct': 1},
  {'word': 'Sorry',      'options': ['Merhaba', 'Lütfen', 'Özür dilerim', 'Teşekkürler'],'correct': 2},
  {'word': 'Yes',        'options': ['Hayır', 'Evet', 'Belki', 'Lütfen'],                'correct': 1},
  {'word': 'Friend',     'options': ['Düşman', 'Öğretmen', 'Arkadaş', 'Aile'],           'correct': 2},
  {'word': 'Water',      'options': ['Yemek', 'Su', 'Süt', 'Kahve'],                     'correct': 1},
];

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, this.category = 'Kelime'});
  final String category;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // ── Yükleme durumu ───────────────────────────────────────────────
  bool _loading = true;
  bool _aiGenerated = false;
  String? _loadError;

  // ── Sorular ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _questions = const [];

  // ── Quiz durumu ──────────────────────────────────────────────────
  int _currentIndex = 0;
  int? _selectedChoice;
  int _correctCount = 0;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(activity: LearningActivity.quiz);
    _loadQuestions();
  }

  @override
  void dispose() {
    StudySessionTracker.stop();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    final level = await AppPrefs.getUserLevel();
    final aiQuestions = await GeminiService.generateQuiz(
      level: level,
      category: widget.category,
    );

    if (!mounted) return;

    if (aiQuestions != null && aiQuestions.isNotEmpty) {
      setState(() {
        _questions = aiQuestions;
        _aiGenerated = true;
        _loading = false;
        _currentIndex = 0;
        _selectedChoice = null;
        _correctCount = 0;
        _answered = false;
      });
    } else {
      setState(() {
        _questions = List<Map<String, dynamic>>.from(_fallbackQuestions);
        _aiGenerated = false;
        _loading = false;
        _loadError = 'Gemini\'ye ulaşılamadı — hazır sorular kullanıldı';
      });
    }
  }

  void _onSelect(int i) {
    if (_answered) return;
    final correct = _questions[_currentIndex]['correct'] as int;
    final isCorrect = i == correct;
    setState(() {
      _selectedChoice = i;
      _answered = true;
      if (isCorrect) _correctCount++;
    });
    unawaited(_feedback(isCorrect));
  }

  Future<void> _feedback(bool correct) async {
    if (!await AppPrefs.getSoundEffectsEnabled()) return;
    if (correct) {
      SystemSound.play(SystemSoundType.click);
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedChoice = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    // Skoru stats'a kaydet
    await StatsStore.bumpSkill(LearningActivity.quiz, minutes: _correctCount);
    await StatsStore.recomputeBadges();

    if (!mounted) return;
    _showResult();
  }

  void _showResult() {
    final total = _questions.length;
    final p = ((_correctCount / total) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('Quiz bitti! '),
            Text(p >= 80 ? '🎉' : p >= 50 ? '👍' : '💪'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_correctCount / $total doğru',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text('%$p başarı',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _correctCount / total,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  p >= 80 ? Colors.green : p >= 50 ? Colors.orange : Colors.red,
                ),
              ),
            ),
            if (_aiGenerated) ...[
              const SizedBox(height: 10),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Yeni quiz üret
              _loadQuestions();
            },
            child: const Text('Tekrar'),
          ),
          TextButton.icon(
            onPressed: () {
              Share.share(
                'İngilizce Öğren quiz sonucum: $_correctCount/$total doğru, %$p başarı!',
              );
            },
            icon: const Icon(Icons.share, size: 20),
            label: const Text('Paylaş'),
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
              child: _loading ? _buildLoading(context) : _buildQuiz(context, spacing),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTheme.buildAppBar(context, 'Quiz'),
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
                      'Gemini AI sorular hazırlıyor...',
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

  Widget _buildQuiz(BuildContext context, double spacing) {
    final q = _questions[_currentIndex];
    final options = (q['options'] as List).cast<String>();
    final correctIndex = q['correct'] as int;
    final showFeedback = _answered && _selectedChoice != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTheme.buildAppBar(context, 'Quiz'),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI badge + hata mesajı
                if (_loadError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 13, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _loadError!,
                            style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
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

                SizedBox(height: spacing),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
                SizedBox(height: spacing * 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_questions.length}',
                      style: TextStyle(fontSize: Responsive.fontSizeCaption(context), color: Colors.grey.shade600),
                    ),
                    Text(
                      '$_correctCount doğru',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeCaption(context),
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: spacing * 3),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.cardPadding(context) * 1.5,
                      vertical: Responsive.cardPadding(context),
                    ),
                    decoration: AppTheme.cardDecorationFor(context),
                    child: Text(
                      q['word'] as String,
                      style: TextStyle(
                        fontSize: Responsive.fontSizeDisplay(context),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 2),
                Text(
                  'Doğru anlamı seç:',
                  style: TextStyle(
                    fontSize: Responsive.fontSizeBody(context),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(height: spacing),

                ...List.generate(options.length, (i) {
                  final isSelected = _selectedChoice == i;
                  final isCorrect = i == correctIndex;
                  Color? bgColor;
                  if (showFeedback) {
                    if (isCorrect) {
                      bgColor = Colors.green.shade50;
                    } else if (isSelected) {
                      bgColor = Colors.red.shade50;
                    }
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: Material(
                      color: bgColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                      child: InkWell(
                        onTap: _answered ? null : () => _onSelect(i),
                        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                        child: Container(
                          padding: EdgeInsets.all(Responsive.cardPadding(context)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                            border: Border.all(
                              color: showFeedback && isCorrect
                                  ? Colors.green
                                  : (showFeedback && isSelected ? Colors.red : (isSelected ? AppTheme.primary : Colors.grey.shade200)),
                              width: (isSelected || (showFeedback && isCorrect)) ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                showFeedback && isCorrect
                                    ? Icons.check_circle
                                    : (showFeedback && isSelected && !isCorrect
                                        ? Icons.cancel
                                        : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off)),
                                size: Responsive.iconSizeSmall(context),
                                color: showFeedback && isCorrect
                                    ? Colors.green
                                    : (showFeedback && isSelected && !isCorrect ? Colors.red : AppTheme.primary),
                              ),
                              SizedBox(width: Responsive.spacing(context)),
                              Expanded(
                                child: Text(
                                  options[i],
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeBody(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: spacing),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(top: spacing * 0.5),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _answered ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: Responsive.buttonPaddingVertical(context)),
                minimumSize: Size(0, Responsive.minTouchTarget(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                ),
              ),
              child: Text(_currentIndex < _questions.length - 1 ? 'İleri' : 'Bitir'),
            ),
          ),
        ),
      ],
    );
  }
}
