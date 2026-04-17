import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/vocabulary_book_service.dart';
import '../services/study_session_tracker.dart';
import '../services/stats_store.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';

class WordDetailPage extends StatefulWidget {
  const WordDetailPage({
    super.key,
    required this.word,
    required this.meaning,
    required this.example,
    this.vocabularyEntryId,
  });
  final String word;
  final String meaning;
  final String example;

  /// Kelime defterinden açıldıysa dolu; "Öğrendim" bu kaydı siler.
  final String? vocabularyEntryId;

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  bool _adding = false;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(activity: LearningActivity.vocabulary);
    _tts.setLanguage('en-US');
  }

  @override
  void dispose() {
    StudySessionTracker.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    if (_speaking) return;
    setState(() => _speaking = true);
    await _tts.speak(widget.word);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _addToVocabulary() async {
    if (_adding) return;
    setState(() => _adding = true);
    try {
      final dup = await VocabularyBookService.containsWord(widget.word, widget.meaning);
      if (dup) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu kelime zaten defterinde'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await VocabularyBookService.addWord(
        word: widget.word,
        meaning: widget.meaning,
        example: widget.example,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kelime defterine eklendi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _onLearned() async {
    if (widget.vocabularyEntryId != null && widget.vocabularyEntryId!.isNotEmpty) {
      if (_removing) return;
      setState(() => _removing = true);
      try {
        await VocabularyBookService.removeById(widget.vocabularyEntryId!);
        if (!mounted) return;
        Navigator.pop(context, true);
      } finally {
        if (mounted) setState(() => _removing = false);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromVocab = widget.vocabularyEntryId != null &&
        widget.vocabularyEntryId!.isNotEmpty;
    final exampleText = widget.example.trim().isEmpty
        ? 'Henüz örnek cümle eklenmedi.'
        : widget.example;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: ResponsivePage(
        scroll: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildAppBar(context, 'Kelime'),
            SizedBox(height: Responsive.gapMd(context)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Responsive.cardPadding(context) * 1.2),
                      decoration: AppTheme.cardDecorationFor(context),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.word,
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeDisplay(context),
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _speaking ? null : _speak,
                                icon: Icon(
                                  _speaking ? Icons.volume_up : Icons.volume_up,
                                  color: _speaking ? Colors.grey : AppTheme.primary,
                                  size: Responsive.iconSizeMedium(context),
                                ),
                                tooltip: 'Telaffuz',
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.gapSm(context)),
                          Text(
                            widget.meaning,
                            style: TextStyle(
                              fontSize: Responsive.fontSizeTitleSmall(context),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Responsive.gapLg(context)),
                    Text(
                      'Örnek cümle',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeBody(context),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: Responsive.gapSm(context)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Responsive.cardPadding(context)),
                      decoration: AppTheme.cardDecorationFor(context),
                      child: Text(
                        exampleText,
                        style: TextStyle(
                          fontSize: Responsive.fontSizeBody(context),
                          fontStyle: widget.example.trim().isEmpty
                              ? FontStyle.normal
                              : FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.gapLg(context)),
                    if (fromVocab)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _removing ? null : _onLearned,
                          icon: _removing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, size: 20),
                          label: Text(_removing ? 'Siliniyor...' : 'Öğrendim'),
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
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _adding ? null : _addToVocabulary,
                              icon: _adding
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.star_border, size: 20),
                              label: Text(_adding ? 'Ekleniyor...' : 'Deftere ekle'),
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
                          SizedBox(width: Responsive.gapSm(context)),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onLearned,
                              icon: const Icon(Icons.check, size: 20),
                              label: const Text('Öğrendim'),
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
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
