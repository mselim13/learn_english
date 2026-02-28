import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, this.category = 'Words'});
  final String category;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentIndex = 0;
  int? _selectedChoice;
  int _correctCount = 0;
  bool _answered = false;
  final List<Map<String, dynamic>> _questions = [
    {'word': 'Hello', 'options': ['Merhaba', 'Hoşça kal', 'Teşekkürler', 'Evet'], 'correct': 0},
    {'word': 'Thank you', 'options': ['Özür dilerim', 'Teşekkürler', 'Lütfen', 'Hayır'], 'correct': 1},
    {'word': 'Goodbye', 'options': ['Merhaba', 'Evet', 'Hoşça kal', 'Lütfen'], 'correct': 2},
    {'word': 'Please', 'options': ['Teşekkürler', 'Lütfen', 'Özür dilerim', 'Evet'], 'correct': 1},
    {'word': 'Sorry', 'options': ['Merhaba', 'Lütfen', 'Özür dilerim', 'Teşekkürler'], 'correct': 2},
    {'word': 'Yes', 'options': ['Hayır', 'Evet', 'Belki', 'Lütfen'], 'correct': 1},
    {'word': 'Friend', 'options': ['Düşman', 'Öğretmen', 'Arkadaş', 'Aile'], 'correct': 2},
    {'word': 'Water', 'options': ['Yemek', 'Su', 'Süt', 'Kahve'], 'correct': 1},
  ];

  void _onSelect(int i) {
    if (_answered) return;
    final q = _questions[_currentIndex];
    final correct = q['correct'] as int;
    setState(() {
      _selectedChoice = i;
      _answered = true;
      if (i == correct) _correctCount++;
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedChoice = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final p = (_correctCount / _questions.length * 100).round();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz bitti!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_correctCount / ${_questions.length} doğru',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text('%$p başarı', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          TextButton.icon(
            onPressed: () {
              Share.share(
                'Learn English quiz sonucum: $_correctCount/${_questions.length} doğru, %$p başarı! 🎉',
              );
            },
            icon: const Icon(Icons.share, size: 20),
            label: const Text('Paylaş'),
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
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final options = q['options'] as List<String>;
    final correctIndex = q['correct'] as int;
    final showFeedback = _answered && _selectedChoice != null;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildAppBar(context, 'Quiz'),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AppTheme.primaryLight.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentIndex + 1} / ${_questions.length}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: AppTheme.cardDecoration,
                  child: Text(
                    q['word'] as String,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Doğru anlamı seç:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(options.length, (i) {
                final isSelected = _selectedChoice == i;
                final isCorrect = i == correctIndex;
                Color? bgColor;
                if (showFeedback) {
                  if (isCorrect) bgColor = Colors.green.shade50;
                  else if (isSelected && !isCorrect) bgColor = Colors.red.shade50;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: bgColor ?? Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: _answered ? null : () => _onSelect(i),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: showFeedback && isCorrect
                                ? Colors.green
                                : (showFeedback && isSelected ? Colors.red : (isSelected ? AppTheme.primary : Colors.grey.shade200!)),
                            width: (isSelected || (showFeedback && isCorrect)) ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              showFeedback && isCorrect
                                  ? Icons.check_circle
                                  : (showFeedback && isSelected && !isCorrect ? Icons.cancel : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off)),
                              color: showFeedback && isCorrect
                                  ? Colors.green
                                  : (showFeedback && isSelected && !isCorrect ? Colors.red : AppTheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[i],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _answered ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? 'İleri' : 'Bitir',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
