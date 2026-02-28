import 'dart:math';
import 'package:flutter/material.dart';
import 'word_detail_page.dart';
import 'flashcard_page.dart';
import '../theme/app_theme.dart';

class VocabularyBookPage extends StatefulWidget {
  const VocabularyBookPage({super.key});

  @override
  State<VocabularyBookPage> createState() => _VocabularyBookPageState();
}

class _VocabularyBookPageState extends State<VocabularyBookPage> {
  String _searchQuery = '';
  final List<Map<String, String>> _saved = [
    {'word': 'Hello', 'meaning': 'Merhaba', 'example': 'Hello, how are you?'},
    {'word': 'Thank you', 'meaning': 'Teşekkürler', 'example': 'Thank you for your help.'},
    {'word': 'Please', 'meaning': 'Lütfen', 'example': 'Please come in.'},
    {'word': 'Goodbye', 'meaning': 'Hoşça kal', 'example': 'Goodbye!'},
    {'word': 'Friend', 'meaning': 'Arkadaş', 'example': 'She is my friend.'},
    {'word': 'Water', 'meaning': 'Su', 'example': 'Can I have water?'},
    {'word': 'Understand', 'meaning': 'Anlamak', 'example': 'Do you understand?'},
    {'word': 'Speak', 'meaning': 'Konuşmak', 'example': 'I speak English.'},
  ];

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
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Yeni kelime ekle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: wordController,
                decoration: InputDecoration(
                  labelText: 'Kelime (İngilizce)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: meaningController,
                decoration: InputDecoration(
                  labelText: 'Anlam (Türkçe)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                        setState(() {
                          _saved.add({
                            'word': word,
                            'meaning': meaning,
                            'example': '',
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Ekle'),
                    ),
                  ),
                ],
              ),
            ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bölümü
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kelime defteri',
                      style: TextStyle(
                        fontSize: 24,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // Kelime Sayısı Bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredWords.length,
                itemBuilder: (context, i) {
                  final w = _filteredWords[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordDetailPage(
                            word: w['word']!,
                            meaning: w['meaning']!,
                            example: w['example']!,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                              radius: 22,
                              backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                              child: Text(
                                w['word']![0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w['word']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    w['meaning']!,
                                    style: TextStyle(
                                      fontSize: 14,
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