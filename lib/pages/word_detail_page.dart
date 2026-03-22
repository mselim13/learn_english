import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/vocabulary_book_service.dart';
import '../theme/app_theme.dart';

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
    _tts.setLanguage('en-US');
  }

  @override
  void dispose() {
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppTheme.buildAppBar(context, 'Kelime'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.word,
                                  style: const TextStyle(
                                    fontSize: 28,
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
                                  size: 32,
                                ),
                                tooltip: 'Telaffuz',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.meaning,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Örnek cümle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration,
                      child: Text(
                        exampleText,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: widget.example.trim().isEmpty
                              ? FontStyle.normal
                              : FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onLearned,
                              icon: const Icon(Icons.check, size: 20),
                              label: const Text('Öğrendim'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
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
