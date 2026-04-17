import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/study_session_tracker.dart';
import '../services/stats_store.dart';

class PracticeRoomPage extends StatefulWidget {
  const PracticeRoomPage({super.key, this.mode = 'speaking'});
  final String mode; // 'speaking' | 'writing'

  @override
  State<PracticeRoomPage> createState() => _PracticeRoomPageState();
}

class _PracticeRoomPageState extends State<PracticeRoomPage> {
  final _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();

  bool _speechReady = false;
  String _recognizedText = '';
  String _speechStatus = '';

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(
      activity: widget.mode == 'speaking'
          ? LearningActivity.speaking
          : LearningActivity.writing,
    );
    if (widget.mode == 'speaking') {
      _initSpeech();
    }
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (mounted) setState(() => _speechStatus = status);
      },
      onError: (error) {
        if (mounted) {
          setState(() => _speechStatus = error.errorMsg);
        }
      },
    );
    if (mounted) setState(() {});
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
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    StudySessionTracker.stop();
    _controller.dispose();
    if (_speech.isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeaking = widget.mode == 'speaking';
    final pad = Responsive.horizontalPadding(context);
    final spacing = Responsive.spacing(context);
    final topics = isSpeaking
        ? ['Kendini tanıt', 'Gününü anlat', 'En sevdiğin yemek', 'Tatil planları', 'Hobilerin']
        : ['Kendini tanıt', 'Bir anını yaz', 'Hayalindeki iş', 'Sevdiğin bir yer', 'Öneri mektubu'];
    final listening = isSpeaking && _speech.isListening;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.buildAppBar(context, isSpeaking ? 'Konuşma pratiği' : 'Yazma pratiği'),
                  SizedBox(height: spacing),
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
                      itemCount: topics.length,
                      separatorBuilder: (_, __) => SizedBox(width: spacing),
                      itemBuilder: (context, i) {
                        return ActionChip(
                          label: Text(
                            topics[i],
                            style: TextStyle(fontSize: Responsive.fontSizeBodySmall(context)),
                          ),
                          onPressed: () {},
                          backgroundColor: i == 0 ? AppTheme.primaryLight.withOpacity(0.5) : Colors.white,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Responsive.cardPadding(context)),
                    decoration: AppTheme.cardDecorationFor(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konu',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeCaption(context),
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: spacing * 0.5),
                        Text(
                          'Kendini kısa bir cümleyle tanıt.',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitleSmall(context),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing * 2),
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
                              color: listening ? Colors.red.shade100 : AppTheme.primaryLight.withOpacity(0.5),
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
                    SizedBox(height: spacing),
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
                    if (_speechStatus.isNotEmpty && listening)
                      Padding(
                        padding: EdgeInsets.only(top: spacing * 0.5),
                        child: Center(
                          child: Text(
                            _speechStatus,
                            style: TextStyle(
                              fontSize: Responsive.fontSizeCaption(context),
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: spacing),
                    Text(
                      'Algılanan metin (İngilizce)',
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
                      'Cevabını yaz:',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeBody(context),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: spacing),
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
                      ),
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
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
                      child: const Text('Gönder'),
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
