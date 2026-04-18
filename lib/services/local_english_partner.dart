import 'dart:math';

/// Lightweight offline English partner.
///
/// Not a real LLM. It focuses on:
/// - mirroring the user's message
/// - suggesting a more natural English phrasing
/// - asking a concrete follow-up question
class LocalEnglishPartner {
  LocalEnglishPartner._();

  static final _rand = Random();

  static String _snippet(String s, {int max = 120}) {
    final t = s.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.length <= max) return t;
    return '${t.substring(0, max - 3)}...';
  }

  static bool _looksTurkish(String s) =>
      RegExp(r'[ğüşıöçĞÜŞİÖÇİı]').hasMatch(s);

  static bool _looksEnglish(String s) =>
      RegExp(r'[a-zA-Z]').hasMatch(s) && !_looksTurkish(s);

  static String _maybeCorrectEnglish(String s) {
    var t = s.trim();
    if (t.isEmpty) return t;
    // Basic fixes: i -> I, spacing, duplicate punctuation.
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    t = t.replaceAll(RegExp(r'\s+([?.!,])'), r'$1');
    t = t.replaceFirstMapped(
      RegExp(r'([?.!,]){2,}$'),
      (m) => m.group(0)![0],
    );
    t = t.replaceFirstMapped(RegExp(r'^(i)\b'), (_) => 'I');
    t = t.replaceAllMapped(RegExp(r"\bi'm\b", caseSensitive: false), (_) => "I'm");
    t = t.replaceAllMapped(RegExp(r"\bi dont\b", caseSensitive: false), (_) => "I don't");
    t = t.replaceAllMapped(RegExp(r"\bim\b", caseSensitive: false), (_) => "I'm");
    return t;
  }

  static String _followUpFor(String lower) {
    // Try to ask something specific.
    if (lower.contains('because')) return 'Why do you think that?';
    if (lower.contains('want to')) return 'What’s your plan to do it?';
    if (lower.contains('work')) return 'What do you do for work?';
    if (lower.contains('school') || lower.contains('study')) return 'What are you studying?';
    if (lower.contains('weekend')) return 'What did you do on the weekend?';
    if (lower.contains('today')) return 'What’s one thing you want to do today?';
    if (lower.contains('tomorrow')) return 'What are you going to do tomorrow?';
    if (lower.contains('feel')) return 'What made you feel that way?';
    if (lower.contains('problem')) return 'What’s the main problem, in one sentence?';
    if (lower.contains('?')) return 'What answer do you think is most likely?';
    return _pick([
      'Can you tell me one more detail?',
      'What happened next?',
      'How did that make you feel?',
      'What’s the most important part of that?',
    ]);
  }

  static String generateReply(List<Map<String, String>> messages) {
    String lastUser = '';
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i]['role'] == 'user') {
        lastUser = (messages[i]['content'] ?? '').trim();
        break;
      }
    }

    if (lastUser.isEmpty) {
      return _pick([
        "I'm listening—what would you like to talk about?",
        "Tell me about your day or ask me anything!",
      ]);
    }

    final lower = lastUser.toLowerCase();
    final hasTurkish = _looksTurkish(lastUser);

    if (hasTurkish) {
      final s = _snippet(lastUser, max: 90);
      return 'I understand. Try writing the same idea in simple English.\n'
          'For example: "I want to say: $s."\n'
          '${_followUpFor(lower)}';
    }

    if (RegExp(r'^(hi|hello|hey|good morning|good afternoon|good evening)[\s!.?]*$', caseSensitive: false).hasMatch(lower)) {
      return _pick([
        "Hey! Great to chat. What’s something fun you did recently?",
        "Hello! What topic do you want to practice today?",
        "Hi! Tell me about your weekend in two or three English sentences.",
      ]);
    }

    if (lower.contains('how are you') || lower == "how's it going" || lower.contains('how is it going')) {
      return _pick([
        "I'm doing well, thanks! How about you—what’s one good thing about your week?",
        "All good here! How are you feeling today?",
      ]);
    }

    if (lower.contains('thank') || lower == 'thanks' || lower == 'ty') {
      return _pick([
        "You're welcome! What’s next on your mind?",
        "Anytime! Ask me another question to keep the chat going.",
      ]);
    }

    if (RegExp(r'\b(bye|goodbye|see you|gotta go)\b').hasMatch(lower)) {
      return _pick([
        "See you! A little practice every day really helps.",
        "Take care! Try one English sentence about your plans for tomorrow.",
      ]);
    }

    if (lastUser.contains('?')) {
      return _pick([
        "That’s a good question. In casual English, keep it short and clear—what do you most want to know?",
        "Nice! Everyday questions are often simple and direct—try saying the main point in one line.",
        "I like that you asked. Try answering it yourself in one sentence—it builds confidence.",
      ]);
    }

    if (lower.split(RegExp(r'\s+')).length <= 2 &&
        RegExp(r'^(yes|no|ok|okay|sure|maybe|idk|i do not know)\b', caseSensitive: false)
            .hasMatch(lower)) {
      return _pick([
        "Got it! Can you add a bit more—maybe why you feel that way?",
        "Thanks! Turn that into a full sentence in English.",
      ]);
    }

    if (lower.contains('help') && lower.contains('english')) {
      return _pick([
        "I’m here for that! Pick a situation—ordering food, small talk, or email—and we’ll practice short phrases.",
        "Sure. Tell me your level (beginner or intermediate) and one place you need English.",
      ]);
    }

    // English (or mixed): mirror + suggest + follow-up
    if (_looksEnglish(lastUser)) {
      final corrected = _maybeCorrectEnglish(lastUser);
      final mirror = _snippet(lastUser, max: 120);
      final follow = _followUpFor(lower);
      if (corrected != lastUser.trim()) {
        return 'Got it: "$mirror"\n'
            'A more natural version: "$corrected"\n'
            '$follow';
      }
      return 'Got it: "$mirror"\n$follow';
    }

    // Fallback for mixed/unknown
    final mirror = _snippet(lastUser, max: 110);
    return 'Thanks! I got: "$mirror"\n${_followUpFor(lower)}';
  }

  static String _pick(List<String> options) => options[_rand.nextInt(options.length)];
}
