import 'package:flutter/material.dart';
import '../services/app_prefs.dart';
import '../utils/responsive.dart';
import 'result_page.dart';

class PlacementTestQuestion {
  const PlacementTestQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

class PlacementTestPage extends StatefulWidget {
  const PlacementTestPage({super.key});

  @override
  State<PlacementTestPage> createState() => _PlacementTestPageState();
}

class _PlacementTestPageState extends State<PlacementTestPage> {
  static const _questions = <PlacementTestQuestion>[
    PlacementTestQuestion(
      prompt: 'Choose the correct sentence:',
      options: ['She go to school every day.', 'She goes to school every day.', 'She going to school every day.', 'She gone to school every day.'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'I ____ a coffee right now.',
      options: ['drink', 'drinks', 'am drinking', 'drank'],
      correctIndex: 2,
    ),
    PlacementTestQuestion(
      prompt: 'We ____ in Ankara last year.',
      options: ['live', 'lived', 'are living', 'has lived'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'There isn’t ____ milk in the fridge.',
      options: ['many', 'a', 'any', 'some'],
      correctIndex: 2,
    ),
    PlacementTestQuestion(
      prompt: 'Which one is a synonym of “happy”?',
      options: ['angry', 'glad', 'tired', 'late'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'If it ____ tomorrow, we will stay at home.',
      options: ['rain', 'rains', 'rained', 'will rain'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'I have lived here ____ 2018.',
      options: ['for', 'since', 'during', 'from'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'He ____ to the gym twice a week.',
      options: ['go', 'goes', 'going', 'gone'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'Choose the correct question:',
      options: ['Where you are from?', 'Where are you from?', 'Where you from are?', 'From where you are?'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'I’m not as tall ____ my brother.',
      options: ['than', 'as', 'like', 'to'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'She ____ her homework yet.',
      options: ['didn’t finish', 'hasn’t finished', 'isn’t finishing', 'doesn’t finished'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'This is the best movie I ____.',
      options: ['ever see', 'have ever seen', 'has ever seen', 'ever saw'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'Choose the correct form: “When I arrived, they ____.”',
      options: ['sleep', 'were sleeping', 'slept', 'have slept'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'I wish I ____ more time.',
      options: ['have', 'had', 'will have', 'has'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'He said he ____ me later.',
      options: ['will call', 'would call', 'calls', 'called'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'If I ____ you, I would apologize.',
      options: ['am', 'were', 'was', 'will be'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'By the time we got there, the film ____.',
      options: ['already started', 'had already started', 'has already started', 'was already starting'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'Not only ____ late, but he also forgot his wallet.',
      options: ['he was', 'was he', 'he is', 'is he'],
      correctIndex: 1,
    ),
    PlacementTestQuestion(
      prompt: 'The report needs ____ before Friday.',
      options: ['to finish', 'finishing', 'finished', 'to be finished'],
      correctIndex: 3,
    ),
    PlacementTestQuestion(
      prompt: 'Choose the closest meaning: “I can’t put up with this noise.”',
      options: ['I can’t tolerate this noise.', 'I can’t create this noise.', 'I can’t find this noise.', 'I can’t increase this noise.'],
      correctIndex: 0,
    ),
  ];

  int _index = 0;
  final Map<int, int> _answers = {}; // questionIndex -> selectedOption

  int? get _selected => _answers[_index];

  double get _progress => (_index + 1) / _questions.length;

  String _levelForScore(int score) {
    // 20 questions
    if (score <= 4) return 'A1';
    if (score <= 8) return 'A2';
    if (score <= 12) return 'B1';
    if (score <= 15) return 'B2';
    if (score <= 18) return 'C1';
    return 'C2';
  }

  Future<void> _finish() async {
    var correct = 0;
    for (var i = 0; i < _questions.length; i++) {
      final a = _answers[i];
      if (a != null && a == _questions[i].correctIndex) correct++;
    }

    final level = _levelForScore(correct);
    await AppPrefs.setPlacementTestScore(correct);
    await AppPrefs.setUserLevel(level);
    await AppPrefs.setPlacementTestCompleted(true);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ResultPage()),
      (r) => false,
    );
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      _finish();
      return;
    }
    setState(() => _index++);
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_index];
    final canNext = _selected != null;
    final titleSize = Responsive.fontSizeTitle(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Seviye Testi', style: TextStyle(fontSize: titleSize)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _index == 0 ? () => Navigator.of(context).maybePop() : _back,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
            child: Padding(
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: _progress),
                  SizedBox(height: Responsive.gapMd(context)),
                  Text(
                    'Soru ${_index + 1} / ${_questions.length}',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBodySmall(context),
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.gapSm(context)),
                  Text(
                    q.prompt,
                    style: TextStyle(
                      fontSize: Responsive.fontSizeBody(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.gapMd(context)),
                  Expanded(
                    child: ListView.separated(
                      itemCount: q.options.length,
                      separatorBuilder: (_, i) => SizedBox(height: Responsive.gapXs(context)),
                      itemBuilder: (context, i) {
                        final selected = _selected == i;
                        return Material(
                          color: selected ? Colors.deepPurple.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                            onTap: () => setState(() => _answers[_index] = i),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.cardPadding(context),
                                vertical: Responsive.gapSm(context),
                              ),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: i,
                                    groupValue: _selected,
                                    onChanged: (v) => setState(() => _answers[_index] = v ?? i),
                                  ),
                                  Expanded(
                                    child: Text(
                                      q.options[i],
                                      style: TextStyle(fontSize: Responsive.fontSizeBody(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: Responsive.gapMd(context)),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _index == 0 ? null : _back,
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(0, Responsive.minTouchTarget(context)),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.buttonPaddingVertical(context),
                            ),
                          ),
                          child: const Text('Geri'),
                        ),
                      ),
                      SizedBox(width: Responsive.gapSm(context)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canNext ? _next : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, Responsive.minTouchTarget(context)),
                            padding: EdgeInsets.symmetric(
                              vertical: Responsive.buttonPaddingVertical(context),
                            ),
                            backgroundColor: const Color(0xFF7A3EC8),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_index == _questions.length - 1 ? 'Bitir' : 'İleri'),
                        ),
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

