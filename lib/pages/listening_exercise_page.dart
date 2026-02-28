import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    for (var i = 0; i < _sentences.length; i++) {
      _writingControllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTheme.buildAppBar(context, 'Dinleme'),
              const SizedBox(height: 24),
              Text(
                'Cümleyi dinle ve dinlediklerini yaz. İleride kontrol edilecek.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: AppTheme.cardDecoration,
                child: Column(
                  children: [
                    Icon(
                      Icons.headphones,
                      size: 64,
                      color: AppTheme.primary.withOpacity(0.8),
                    ),
                    const SizedBox(height: 24),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _showText
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        '••••••••••••••••••••',
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 4,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      secondChild: Text(
                        _sentences[_currentIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () async {
                      setState(() => _playing = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _playing = false);
                    },
                    icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Dinlediklerini yaz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
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
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showText = !_showText),
                  icon: Icon(_showText ? Icons.visibility_off : Icons.visibility),
                  label: Text(_showText ? 'Metni gizle' : 'Metni göster'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
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
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  IconButton(
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
    );
  }
}
