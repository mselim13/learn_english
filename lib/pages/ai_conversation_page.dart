import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../services/ai_conversation_service.dart';
import '../services/offline_llama_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class _ChatTurn {
  const _ChatTurn({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

class AiConversationPage extends StatefulWidget {
  const AiConversationPage({super.key});

  @override
  State<AiConversationPage> createState() => _AiConversationPageState();
}

class _AiConversationPageState extends State<AiConversationPage> {
  static const _welcomeTemplates =
      "Hi! I'm your English practice partner.\n"
      "You're in offline basic mode (no GGUF model), so my replies are simpler.\n"
      "If you add a GGUF model as chat_model.gguf, I can chat much more naturally.";

  static const _welcomeGguf =
      "Hi! Your offline GGUF model is loaded—I'll reply in English. Send a message!";

  final _scroll = ScrollController();
  final _input = TextEditingController();
  final _speech = SpeechToText();
  final _tts = FlutterTts();

  late List<_ChatTurn> _turns;

  bool _hasGguf = false;

  bool _speechReady = false;
  bool _listening = false;
  String _partialSpeech = '';
  bool _sending = false;
  String? _ttsBusyId;

  @override
  void initState() {
    super.initState();
    _turns = [
      const _ChatTurn(isUser: false, text: _welcomeTemplates),
    ];
    _initSpeech();
    _initTts();
    _refreshModelState();
  }

  Future<void> _refreshModelState() async {
    final ok = await OfflineLlamaService.hasLocalModelFile();
    if (!mounted) return;
    setState(() {
      _hasGguf = ok;
      if (_turns.length == 1 && !_turns[0].isUser) {
        _turns[0] = _ChatTurn(isUser: false, text: _hasGguf ? _welcomeGguf : _welcomeTemplates);
      }
    });
  }

  String get _statusLine => _hasGguf ? 'Offline GGUF (llama.cpp)' : 'Offline templates';

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onStatus: (s) {
        if (!mounted) return;
        if (s == 'notListening') {
          setState(() {
            _listening = false;
            _applySpeechToInput();
          });
        }
      },
      onError: (_) {},
    );
    if (mounted) setState(() => _speechReady = ok);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _ttsBusyId = null);
    });
  }

  void _applySpeechToInput() {
    final t = _partialSpeech.trim();
    if (t.isEmpty) return;
    final cur = _input.text.trim();
    _input.text = cur.isEmpty ? t : '$cur $t';
    _input.selection = TextSelection.collapsed(offset: _input.text.length);
    _partialSpeech = '';
  }

  Future<void> _toggleListen() async {
    if (!_speechReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ses tanıma kullanılamıyor veya izin verilmedi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    if (_speech.isListening) {
      await _speech.stop();
      return;
    }
    _partialSpeech = '';
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (SpeechRecognitionResult r) {
        if (!mounted) return;
        setState(() => _partialSpeech = r.recognizedWords);
      },
      localeId: 'en_US',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
    if (mounted) setState(() {});
  }

  static String _englishForTts(String full) {
    final s = full.trim();
    if (s.length < 4 || !s.toUpperCase().startsWith('EN:')) return full;
    final upper = s.toUpperCase();
    final trIdx = upper.indexOf('\nTR:');
    if (trIdx == -1) return s.substring(3).trim();
    return s.substring(3, trIdx).trim();
  }

  Future<void> _speakAssistant(String id, String text) async {
    if (_ttsBusyId == id) {
      await _tts.stop();
      setState(() => _ttsBusyId = null);
      return;
    }
    await _tts.stop();
    setState(() => _ttsBusyId = id);
    await _tts.speak(_englishForTts(text));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  List<Map<String, String>> _apiMessages() {
    return [
      {'role': 'system', 'content': AiConversationService.systemPrompt},
      ..._turns.map((t) => {
            'role': t.isUser ? 'user' : 'assistant',
            'content': t.text,
          }),
    ];
  }

  Future<void> _sendUserText(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _turns.add(_ChatTurn(isUser: true, text: text));
      _sending = true;
    });
    _input.clear();
    _scrollToBottom();

    try {
      final result = await AiConversationService.completeWithSource(_apiMessages());
      if (!mounted) return;
      setState(() {
        _turns.add(_ChatTurn(isUser: false, text: result.text));
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _turns.removeLast();
        _sending = false;
      });
      _input.text = text;
      final msg = e.toString().replaceFirst('StateError: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isEmpty ? 'Something went wrong. Please try again.' : msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearChat() {
    setState(() {
      _turns
        ..clear()
        ..add(_ChatTurn(isUser: false, text: _hasGguf ? _welcomeGguf : _welcomeTemplates));
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    OfflineLlamaService.unload();
    _scroll.dispose();
    _input.dispose();
    if (_speech.isListening) _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İngilizce AI',
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitle(context),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          _statusLine,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                    onSelected: (v) {
                      if (v == 'clear') _clearChat();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'clear', child: Text('Sohbeti temizle')),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Text(
                'Transkript',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.fromLTRB(pad, 0, pad, 12),
                      itemCount: _turns.length + (_sending ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (_sending && i == _turns.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primary.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Typing a reply...',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        }
                        final turn = _turns[i];
                        final bubbleId = '$i-${turn.isUser}';
                        return _TranscriptBubble(
                          turn: turn,
                          bubbleId: bubbleId,
                          ttsBusyId: _ttsBusyId,
                          onSpeak: () => _speakAssistant(bubbleId, turn.text),
                        );
                      },
                    ),
            ),
            if (_listening && _partialSpeech.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Text(
                  _partialSpeech,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            Container(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 8 + bottomInset),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: _listening ? 'Stop listening' : 'Speak (English)',
                      onPressed: _toggleListen,
                      icon: Icon(
                        _listening ? Icons.mic : Icons.mic_none_rounded,
                        color: _listening ? Colors.red : AppTheme.primary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sending ? null : _sendUserText,
                        decoration: InputDecoration(
                          hintText: 'Write in English or Turkish...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _sending ? null : () => _sendUserText(_input.text),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  const _TranscriptBubble({
    required this.turn,
    required this.bubbleId,
    required this.ttsBusyId,
    required this.onSpeak,
  });

  final _ChatTurn turn;
  final String bubbleId;
  final String? ttsBusyId;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final isUser = turn.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.86,
          ),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUser) ...[
                    Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Sesli oku',
                      onPressed: onSpeak,
                      icon: Icon(
                        ttsBusyId == bubbleId ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                  if (isUser)
                    Text(
                      'Sen',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  boxShadow: [
                    if (!isUser)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    turn.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: isUser ? Colors.white : Colors.grey.shade900,
                    ),
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
