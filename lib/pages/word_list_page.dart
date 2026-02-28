import 'package:flutter/material.dart';
import 'word_detail_page.dart';
import 'flashcard_page.dart';
import '../theme/app_theme.dart';

class WordListPage extends StatefulWidget {
  const WordListPage({super.key, required this.category});
  final String category;

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  String _search = '';

  static final Map<String, List<Map<String, String>>> _mockWords = {
    'Words': [],
    'Writing': [
      {'word': 'Letter', 'meaning': 'Mektup', 'example': 'I wrote a letter to my friend.'},
      {'word': 'Sentence', 'meaning': 'Cümle', 'example': 'Write a complete sentence.'},
      {'word': 'Paragraph', 'meaning': 'Paragraf', 'example': 'Each paragraph has a main idea.'},
      {'word': 'Essay', 'meaning': 'Deneme / Kompozisyon', 'example': 'I need to write an essay.'},
      {'word': 'Story', 'meaning': 'Hikaye', 'example': 'She told me a funny story.'},
      {'word': 'Email', 'meaning': 'E-posta', 'example': 'Send me an email when you can.'},
      {'word': 'Note', 'meaning': 'Not', 'example': 'I took notes during the lesson.'},
      {'word': 'Diary', 'meaning': 'Günlük', 'example': 'I write in my diary every night.'},
    ],
    'Speaking': [
      {'word': 'Speak', 'meaning': 'Konuşmak', 'example': 'Can you speak English?'},
      {'word': 'Listen', 'meaning': 'Dinlemek', 'example': 'Listen to the teacher.'},
      {'word': 'Say', 'meaning': 'Söylemek', 'example': 'What did you say?'},
      {'word': 'Tell', 'meaning': 'Anlatmak', 'example': 'Tell me about your day.'},
      {'word': 'Ask', 'meaning': 'Sormak', 'example': 'May I ask a question?'},
      {'word': 'Answer', 'meaning': 'Cevap vermek', 'example': 'Please answer the question.'},
      {'word': 'Pronounce', 'meaning': 'Telaffuz etmek', 'example': 'How do you pronounce this word?'},
      {'word': 'Conversation', 'meaning': 'Sohbet', 'example': 'We had a long conversation.'},
    ],
    'Listening': [
      {'word': 'Hear', 'meaning': 'Duymak', 'example': 'I can hear the music.'},
      {'word': 'Understand', 'meaning': 'Anlamak', 'example': 'Do you understand?'},
      {'word': 'Audio', 'meaning': 'Ses kaydı', 'example': 'Listen to the audio carefully.'},
      {'word': 'Podcast', 'meaning': 'Podcast', 'example': 'I listen to a podcast every morning.'},
      {'word': 'Repeat', 'meaning': 'Tekrarlamak', 'example': 'Can you repeat that?'},
      {'word': 'Clear', 'meaning': 'Net / Anlaşılır', 'example': 'Speak clearly, please.'},
      {'word': 'Accent', 'meaning': 'Aksan', 'example': 'She has a British accent.'},
      {'word': 'Subtitles', 'meaning': 'Altyazı', 'example': 'Turn on the subtitles.'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    var words = _mockWords[category] ?? _mockWords['Words']!;
    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      words = words.where((w) =>
        (w['word'] ?? '').toLowerCase().contains(q) ||
        (w['meaning'] ?? '').toLowerCase().contains(q)).toList();
    }
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: words.isEmpty
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FlashcardPage(
                                  words: words
                                      .map((e) => {
                                            'word': e['word']!,
                                            'meaning': e['meaning']!,
                                          })
                                      .toList(),
                                ),
                              ),
                            ),
                    icon: const Icon(Icons.style, color: AppTheme.primary),
                    tooltip: 'Kartlar',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Kelime veya anlam ara...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${words.length} kelime',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: words.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Sonuç bulunamadı',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Farklı bir kelime veya anlam deneyin.',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() => _search = '');
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: words.length,
                        itemBuilder: (context, i) {
                  final w = words[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.cardDecoration.copyWith(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primaryLight.withOpacity(0.5),
                                child: Text(
                                  (w['word'] ?? '')[0].toUpperCase(),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
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
                              const Icon(Icons.chevron_right, color: AppTheme.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
