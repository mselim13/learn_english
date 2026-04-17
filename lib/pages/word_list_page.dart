import 'package:flutter/material.dart';
import 'word_detail_page.dart';
import 'flashcard_page.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import '../services/study_session_tracker.dart';
import '../services/stats_store.dart';

class WordListPage extends StatefulWidget {
  const WordListPage({super.key, required this.category});
  final String category;

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    StudySessionTracker.start(activity: LearningActivity.vocabulary);
  }

  @override
  void dispose() {
    StudySessionTracker.stop();
    super.dispose();
  }

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
      body: ResponsivePage(
        scroll: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppTheme.primary,
                    size: Responsive.iconSizeSmall(context),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: Responsive.minTouchTarget(context),
                    minHeight: Responsive.minTouchTarget(context),
                  ),
                ),
                SizedBox(width: Responsive.gapSm(context)),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: Responsive.fontSizeTitle(context),
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
                  icon: Icon(Icons.style, color: AppTheme.primary, size: Responsive.iconSizeSmall(context)),
                  tooltip: 'Kartlar',
                ),
              ],
            ),
            SizedBox(height: Responsive.gapSm(context)),
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Kelime veya anlam ara...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.gapMd(context),
                  vertical: Responsive.gapSm(context),
                ),
              ),
            ),
            SizedBox(height: Responsive.gapSm(context)),
            Text(
              '${words.length} kelime',
              style: TextStyle(fontSize: Responsive.fontSizeCaption(context), color: Colors.grey.shade600),
            ),
            SizedBox(height: Responsive.gapSm(context)),
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
                              fontSize: Responsive.fontSizeBody(context),
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Farklı bir kelime veya anlam deneyin.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: Responsive.fontSizeBodySmall(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        setState(() => _search = '');
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: words.length,
                        itemBuilder: (context, i) {
                  final w = words[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: Responsive.gapSm(context)),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
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
                        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                        child: Container(
                          padding: EdgeInsets.all(Responsive.cardPadding(context)),
                          decoration: AppTheme.cardDecorationFor(context).copyWith(
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
                                radius: Responsive.iconSizeMedium(context) * 0.55,
                                backgroundColor: AppTheme.primaryLight.withOpacity(0.5),
                                child: Text(
                                  (w['word'] ?? '')[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                    fontSize: Responsive.fontSizeBody(context),
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
