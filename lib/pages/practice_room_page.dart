import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/app_prefs.dart';
import '../services/study_session_tracker.dart';
import '../services/stats_store.dart';
import '../services/gemini_service.dart';

class PracticeRoomPage extends StatefulWidget {
  const PracticeRoomPage({super.key, this.mode = 'speaking'});
  final String mode; // 'speaking' | 'writing'

  @override
  State<PracticeRoomPage> createState() => _PracticeRoomPageState();
}

class _PracticeRoomPageState extends State<PracticeRoomPage> {
  final _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  // ── Konuşma tanıma ───────────────────────────────────────────────
  bool _speechReady = false;
  String _recognizedText = '';

  // ── AI prompt yükleme ────────────────────────────────────────────
  bool _loadingPrompt = true;
  String? _promptText;
  String _currentTopic = '';

  // ── Değerlendirme ────────────────────────────────────────────────
  bool _submitting = false;

  // ── Konular ──────────────────────────────────────────────────────
  late final List<String> _topics;

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(
      activity: widget.mode == 'speaking'
          ? LearningActivity.speaking
          : LearningActivity.writing,
    );
    _topics = widget.mode == 'speaking'
        ? ['Kendini tanıt', 'Gününü anlat', 'En sevdiğin yemek', 'Tatil planları', 'Hobilerin']
        : ['Kendini tanıt', 'Bir anını yaz', 'Hayalindeki iş', 'Sevdiğin bir yer', 'Öneri mektubu'];
    _currentTopic = _topics.first;

    if (widget.mode == 'speaking') _initSpeech();
    _loadPrompt(_currentTopic);
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (_) {},
      onError: (error) {
        if (mounted) setState(() => _recognizedText = '');
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _loadPrompt(String topic) async {
    setState(() {
      _loadingPrompt = true;
      _promptText = null;
      _recognizedText = '';
      _controller.clear();
    });

    final level = await AppPrefs.getUserLevel();
    final prompt = await GeminiService.generatePrompt(
      level: level,
      topic: topic,
      mode: widget.mode,
    );

    if (!mounted) return;
    setState(() {
      _loadingPrompt = false;
      _promptText = prompt ??
          (widget.mode == 'speaking'
              ? 'Tell me about yourself in a few sentences.'
              : 'Write a short paragraph about yourself.');
    });
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) return;
    if (_speech.isListening) {
      await _speech.stop();
      if (mounted) setState(() {});
      return;
    }
    _recognizedText = '';
    await _speech.listen(
      onResult: _onSpeechResult,
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
    if (mounted) setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _recognizedText = result.recognizedWords);
  }

  Future<void> _submit() async {
    final userText = widget.mode == 'speaking' ? _recognizedText : _controller.text;
    if (userText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.mode == 'speaking'
              ? 'Önce mikrofona konuş!'
              : 'Lütfen bir şeyler yaz!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final level = await AppPrefs.getUserLevel();
    final result = await GeminiService.evaluateResponse(
      level: level,
      topic: _promptText ?? _currentTopic,
      userResponse: userText.trim(),
      mode: widget.mode,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    final score = result?['score'] as int? ?? 0;
    final feedbackTr = result?['feedbackTr'] as String? ?? '';
    final feedback = result?['feedback'] as String? ?? '';

    // Stats'a kaydet
    await StatsStore.bumpSkill(
      widget.mode == 'speaking' ? LearningActivity.speaking : LearningActivity.writing,
      minutes: (score / 10).round(),
    );
    await StatsStore.recomputeBadges();

    if (!mounted) return;
    _showResult(score: score, feedback: feedback, feedbackTr: feedbackTr, aiEvaluated: result != null);
  }

  void _showResult({
    required int score,
    required String feedback,
    required String feedbackTr,
    required bool aiEvaluated,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(widget.mode == 'speaking' ? 'Konuşma değerlendirmesi ' : 'Yazma değerlendirmesi '),
            Text(score >= 80 ? '🎉' : score >= 60 ? '👍' : '💪'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score / 100',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
                  ),
                ),
              ),
              if (feedbackTr.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    feedbackTr,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (aiEvaluated) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 13, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Gemini AI tarafından değerlendirildi',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                Text(
                  'AI değerlendirmesi yapılamadı — skorun kaydedilmedi.',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadPrompt(_currentTopic);
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
    _controller.dispose();
    if (_speech.isListening) _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = widget.mode == 'speaking';
    final pad = Responsive.horizontalPadding(context);
    final spacing = Responsive.spacing(context);
    final listening = isSpeaking && _speech.isListening;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.buildAppBar(context, isSpeaking ? 'Konuşma pratiği' : 'Yazma pratiği'),
                  SizedBox(height: spacing),

                  // Kaydırılabilir içerik (klavye açılınca taşmayı önler)
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Konu chips
                          Text(
                            'Konu seç',
                            style: TextStyle(
                              fontSize: Responsive.fontSizeBodySmall(context),
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: spacing * 0.5),
                          SizedBox(
                            height: Responsive.minTouchTarget(context) + 8,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _topics.length,
                              separatorBuilder: (context, i) => SizedBox(width: spacing * 0.5),
                              itemBuilder: (context, i) {
                                final selected = _topics[i] == _currentTopic;
                                return ActionChip(
                                  label: Text(
                                    _topics[i],
                                    style: TextStyle(
                                      fontSize: Responsive.fontSizeBodySmall(context),
                                      color: selected ? Colors.white : AppTheme.primary,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  onPressed: _loadingPrompt
                                      ? null
                                      : () {
                                          if (_currentTopic == _topics[i]) return;
                                          setState(() => _currentTopic = _topics[i]);
                                          _loadPrompt(_topics[i]);
                                        },
                                  backgroundColor: selected
                                      ? AppTheme.primary
                                      : AppTheme.primaryLight.withValues(alpha: 0.3),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: spacing),

                          // AI prompt kartı
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(Responsive.cardPadding(context)),
                            decoration: AppTheme.cardDecorationFor(context),
                            child: _loadingPrompt
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Gemini AI soru hazırlıyor…',
                                        style: TextStyle(
                                          fontSize: Responsive.fontSizeBodySmall(context),
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.auto_awesome, size: 13, color: Colors.grey.shade500),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Gemini AI',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: spacing * 0.5),
                                      Text(
                                        _promptText ?? '',
                                        style: TextStyle(
                                          fontSize: Responsive.fontSizeTitleSmall(context),
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          SizedBox(height: spacing),

                          // Input section
                          if (isSpeaking) ...[
                            if (!_speechReady)
                              Padding(
                                padding: EdgeInsets.only(bottom: spacing),
                                child: Text(
                                  'Ses tanıma hazırlanıyor veya bu cihazda desteklenmiyor.',
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeBodySmall(context),
                                    color: Colors.orange.shade800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            Center(
                              child: GestureDetector(
                                onTap: _speechReady ? _toggleListening : null,
                                child: Opacity(
                                  opacity: _speechReady ? 1 : 0.5,
                                  child: Container(
                                    width: Responsive.iconSizeLarge(context) * 1.4,
                                    height: Responsive.iconSizeLarge(context) * 1.4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: listening
                                          ? Colors.red.shade100
                                          : AppTheme.primaryLight.withValues(alpha: 0.5),
                                    ),
                                    child: Icon(
                                      listening ? Icons.stop : Icons.mic,
                                      size: Responsive.iconSizeLarge(context),
                                      color: listening ? Colors.red : AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            Center(
                              child: Text(
                                !_speechReady
                                    ? 'Bekleyin...'
                                    : listening
                                        ? 'Dinleniyor… İngilizce konuş'
                                        : 'Mikrofona dokun, konuşmayı başlat',
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context),
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: spacing),
                            Text(
                              'Algılanan metin',
                              style: TextStyle(
                                fontSize: Responsive.fontSizeBodySmall(context),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(Responsive.cardPadding(context)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              constraints: BoxConstraints(minHeight: Responsive.minTouchTarget(context) * 2),
                              child: Text(
                                _recognizedText.isEmpty
                                    ? (listening ? 'Konuşmaya başla…' : 'Metin burada görünecek.')
                                    : _recognizedText,
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context),
                                  color: _recognizedText.isEmpty ? Colors.grey.shade500 : Colors.black87,
                                ),
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Cevabını yaz (İngilizce):',
                              style: TextStyle(
                                fontSize: Responsive.fontSizeBody(context),
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            TextField(
                              controller: _controller,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText: 'Örn: My name is Nihan. I am learning English.',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: spacing * 2),
                        ],
                      ),
                    ),
                  ),

                  // Gönder butonu (klavyeden bağımsız, hep altta)
                  Padding(
                    padding: EdgeInsets.only(top: spacing * 0.5),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_loadingPrompt || _submitting) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.buttonPaddingVertical(context),
                          ),
                          minimumSize: Size(0, Responsive.minTouchTarget(context)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Gönder ve Değerlendir'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
