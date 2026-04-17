import 'dart:math';
import 'package:flutter/material.dart';
import 'word_detail_page.dart';
import 'flashcard_page.dart';
import '../services/vocabulary_book_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class VocabularyBookPage extends StatefulWidget {
  const VocabularyBookPage({super.key});

  @override
  State<VocabularyBookPage> createState() => _VocabularyBookPageState();
}

class _VocabularyBookPageState extends State<VocabularyBookPage> {
  String _searchQuery = '';
  List<Map<String, String>> _saved = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  Future<void> _loadWords() async {
    final list = await VocabularyBookService.loadWords();
    if (!mounted) return;
    setState(() {
      _saved = list;
      _loading = false;
    });
  }

  // Filtrelenmiş listeyi getiren getter
  List<Map<String, String>> get _filteredWords {
    if (_searchQuery.isEmpty) return _saved;
    return _saved.where((w) {
      final word = w['word']!.toLowerCase();
      final meaning = w['meaning']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return word.contains(query) || meaning.contains(query);
    }).toList();
  }

  void _showAddWordDialog(BuildContext context) {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(ctx)),
            child: Builder(
              builder: (ctx) {
                final r = Responsive.horizontalPadding(ctx);
                return Container(
                  padding: EdgeInsets.all(r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Responsive.cardRadius(ctx)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: Responsive.handleWidth(ctx),
                          height: Responsive.handleHeight(ctx),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.gapLg(ctx)),
                      Text(
                        'Yeni kelime ekle',
                        style: TextStyle(
                          fontSize: Responsive.fontSizeTitle(ctx),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: Responsive.gapMd(ctx)),
                      TextField(
                        controller: wordController,
                        decoration: InputDecoration(
                          labelText: 'Kelime (İngilizce)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(ctx) * 0.6),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.gapSm(ctx)),
                      TextField(
                        controller: meaningController,
                        decoration: InputDecoration(
                          labelText: 'Anlam (Türkçe)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(ctx) * 0.6),
                          ),
                        ),
                      ),
                      SizedBox(height: Responsive.gapLg(ctx)),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(color: AppTheme.primary),
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.buttonPaddingVertical(ctx),
                                ),
                                minimumSize: Size(0, Responsive.minTouchTarget(ctx)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Responsive.cardRadius(ctx) * 0.6),
                                ),
                              ),
                              child: const Text('İptal'),
                            ),
                          ),
                          SizedBox(width: Responsive.gapSm(ctx)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final word = wordController.text.trim();
                                final meaning = meaningController.text.trim();
                                if (word.isEmpty || meaning.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Kelime ve anlam alanları zorunludur'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(ctx);
                                VocabularyBookService.addWord(
                                  word: word,
                                  meaning: meaning,
                                ).then((_) => _loadWords());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: Responsive.buttonPaddingVertical(ctx),
                                ),
                                minimumSize: Size(0, Responsive.minTouchTarget(ctx)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Responsive.cardRadius(ctx) * 0.6),
                                ),
                              ),
                              child: const Text('Ekle'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWordDialog(context),
        backgroundColor: AppTheme.primaryLight,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bölümü
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(context),
                Responsive.gapLg(context),
                Responsive.horizontalPadding(context),
                Responsive.gapSm(context),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kelime defteri',
                      style: TextStyle(
                        fontSize: Responsive.fontSizeTitle(context),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_saved.isEmpty) return;
                      final shuffled = List<Map<String, String>>.from(_saved)..shuffle(Random());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FlashcardPage(words: shuffled),
                        ),
                      );
                    },
                    icon: const Icon(Icons.style, color: AppTheme.primary),
                  ),
                ],
              ),
            ),

            // Arama Çubuğu
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: Responsive.gapSm(context),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Kelime ara...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: Responsive.gapSm(context)),
                  ),
                ),
              ),
            ),

            // Kelime Sayısı Bilgisi
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: Responsive.gapSm(context),
              ),
              child: Text(
                _searchQuery.isEmpty
                    ? '${_saved.length} kelime kaydedildi'
                    : '${_filteredWords.length} sonuç bulundu',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ),

            const SizedBox(height: 8),

            // Liste Bölümü
            Expanded(
              child: _filteredWords.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty ? 'Henüz kelime eklemedin' : 'Sonuç bulunamadı',
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: Responsive.horizontalPadding(context)),
                itemCount: _filteredWords.length,
                itemBuilder: (context, i) {
                  final w = _filteredWords[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: Responsive.gapSm(context)),
                    child: InkWell(
                      onTap: () async {
                        final removed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordDetailPage(
                              word: w['word']!,
                              meaning: w['meaning']!,
                              example: w['example'] ?? '',
                              vocabularyEntryId: w['id'],
                            ),
                          ),
                        );
                        if (removed == true && mounted) await _loadWords();
                      },
                      child: Container(
                        padding: EdgeInsets.all(Responsive.cardPadding(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: Responsive.iconSizeSmall(context),
                              backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                              child: Text(
                                (w['word']!.isNotEmpty ? w['word']![0] : '?')
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: Responsive.gapMd(context)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w['word']!,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSizeBody(context),
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    w['meaning']!,
                                    style: TextStyle(
                                      fontSize: Responsive.fontSizeBodySmall(context),
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey.shade300),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}