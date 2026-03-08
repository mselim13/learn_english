import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key, this.words});
  final List<Map<String, String>>? words;

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with SingleTickerProviderStateMixin {
  late List<Map<String, String>> _words;
  int _index = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _words = widget.words ?? [
      {'word': 'Hello', 'meaning': 'Merhaba'},
      {'word': 'Thank you', 'meaning': 'Teşekkürler'},
      {'word': 'Goodbye', 'meaning': 'Hoşça kal'},
      {'word': 'Please', 'meaning': 'Lütfen'},
      {'word': 'Friend', 'meaning': 'Arkadaş'},
    ];
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void _next() {
    _controller.reset();
    if (_index < _words.length - 1) {
      setState(() => _index++);
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    _controller.reset();
    if (_index > 0) {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primary),
          ),
        ),
        body: const Center(
          child: Text('Gösterilecek kelime yok.'),
        ),
      );
    }
    final w = _words[_index];
    final pad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.maxContentWidth(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(pad),
                  child: AppTheme.buildAppBar(context, 'Kartlar'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Text(
                    '${_index + 1} / ${_words.length}',
                    style: TextStyle(
                      fontSize: Responsive.fontSizeCaption(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(height: Responsive.spacing(context) * 2),
                Expanded(
                  child: GestureDetector(
                    onTap: _flip,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final showFront = _animation.value < 0.5;
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(3.14159 * _animation.value),
                        child: showFront
                            ? _buildCard(context, w['word']!, true)
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(3.14159),
                                child: _buildCard(context, w['meaning']!, false),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
                Padding(
                  padding: EdgeInsets.all(pad),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton.filled(
                        onPressed: _index > 0 ? _prev : null,
                        icon: Icon(Icons.arrow_back, size: Responsive.iconSizeMedium(context)),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(Responsive.minTouchTarget(context), Responsive.minTouchTarget(context)),
                        ),
                      ),
                      TextButton(
                        onPressed: _flip,
                        child: Text(
                          'Çevir',
                          style: TextStyle(fontSize: Responsive.fontSizeButton(context)),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: _next,
                        icon: Icon(
                          _index < _words.length - 1 ? Icons.arrow_forward : Icons.check,
                          size: Responsive.iconSizeMedium(context),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(Responsive.minTouchTarget(context), Responsive.minTouchTarget(context)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String text, bool isFront) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.cardPadding(context) * 1.5),
      decoration: AppTheme.cardDecoration.copyWith(
        color: isFront ? Colors.white : AppTheme.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: Responsive.fontSizeDisplay(context),
          fontWeight: FontWeight.bold,
          color: isFront ? AppTheme.primary : Colors.grey.shade800,
        ),
      ),
    );
  }
}
