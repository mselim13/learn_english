import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../services/study_session_tracker.dart';
import '../services/stats_store.dart';

class ListeningExercisePage extends StatefulWidget {
  const ListeningExercisePage({super.key});

  @override
  State<ListeningExercisePage> createState() => _ListeningExercisePageState();
}

class _ListeningExercisePageState extends State<ListeningExercisePage> {
  bool _showText = false;
  bool _playing = false;
  final _sentences = [
    'Hello, how are you today?',
    'Thank you for your help.',
    'I am learning English every day.',
  ];
  int _currentIndex = 0;
  final List<TextEditingController> _writingControllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(activity: LearningActivity.listening);
    for (var i = 0; i < _sentences.length; i++) {
      _writingControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    StudySessionTracker.stop();
    for (final c in _writingControllers) {
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
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTheme.buildAppBar(context, 'Dinleme'),
                  SizedBox(height: spacing * 2),
                  Text(
                    'Cümleyi dinle ve dinlediklerini yaz. İleride kontrol edilecek.',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBodySmall(context),
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: spacing * 3),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(Responsive.cardPadding(context)),
                    decoration: AppTheme.cardDecorationFor(context),
                child: Column(
                  children: [
                    Icon(
                      Icons.headphones,
                      size: Responsive.iconSizeLarge(context),
                      color: AppTheme.primary.withOpacity(0.8),
                    ),
                    SizedBox(height: spacing * 2),
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
              SizedBox(height: spacing * 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () async {
                      setState(() => _playing = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _playing = false);
                    },
                    icon: Icon(
                      _playing ? Icons.stop : Icons.play_arrow,
                      size: Responsive.iconSizeLarge(context) * 0.6,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.7),
                      minimumSize: Size(
                        Responsive.minTouchTarget(context) * 2,
                        Responsive.minTouchTarget(context) * 2,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing * 2),
              Text(
                'Dinlediklerini yaz',
                style: TextStyle(
                  fontSize: Responsive.fontSizeBody(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: spacing),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.cardPadding(context)),
                decoration: AppTheme.cardDecorationFor(context),
                child: TextField(
                  controller: _writingControllers[_currentIndex],
                  focusNode: _focusNodes[_currentIndex],
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Dinlediğin cümleyi buraya yaz...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: Responsive.fontSizeBody(context)),
                ),
              ),
              SizedBox(height: spacing),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showText = !_showText),
                  icon: Icon(
                    _showText ? Icons.visibility_off : Icons.visibility,
                    size: Responsive.iconSizeSmall(context),
                  ),
                  label: Text(
                    _showText ? 'Metni gizle' : 'Metni göster',
                    style: TextStyle(fontSize: Responsive.fontSizeButton(context)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: EdgeInsets.symmetric(
                      vertical: Responsive.buttonPaddingVertical(context),
                    ),
                    minimumSize: Size(0, Responsive.minTouchTarget(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      minimumSize: Size(
                        Responsive.minTouchTarget(context),
                        Responsive.minTouchTarget(context),
                      ),
                    ),
                    onPressed: _currentIndex > 0
                        ? () => setState(() {
                              _currentIndex--;
                              _showText = false;
                            })
                        : null,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${_sentences.length}',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBodySmall(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      minimumSize: Size(
                        Responsive.minTouchTarget(context),
                        Responsive.minTouchTarget(context),
                      ),
                    ),
                    onPressed: _currentIndex < _sentences.length - 1
                        ? () => setState(() {
                              _currentIndex++;
                              _showText = false;
                            })
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
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
