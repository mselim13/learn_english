import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Kelime defteri: kullanıcının eklediği kelimeler (SharedPreferences).
class VocabularyBookService {
  static const _key = 'vocabulary_book_json';

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  /// Tüm kelimeler: her kayıtta `id`, `word`, `meaning`, `example` anahtarları.
  static Future<List<Map<String, String>>> loadWords() async {
    final p = await _prefs;
    final raw = p.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return {
          'id': m['id']?.toString() ?? '',
          'word': m['word']?.toString() ?? '',
          'meaning': m['meaning']?.toString() ?? '',
          'example': m['example']?.toString() ?? '',
        };
      }).where((e) => e['word']!.isNotEmpty && e['meaning']!.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<Map<String, String>> words) async {
    final p = await _prefs;
    await p.setString(_key, jsonEncode(words));
  }

  static Future<void> addWord({
    required String word,
    required String meaning,
    String example = '',
  }) async {
    final w = word.trim();
    final m = meaning.trim();
    if (w.isEmpty || m.isEmpty) return;
    final list = await loadWords();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    list.add({
      'id': id,
      'word': w,
      'meaning': m,
      'example': example.trim(),
    });
    await _save(list);
  }

  static Future<void> removeById(String id) async {
    if (id.isEmpty) return;
    final list = await loadWords();
    list.removeWhere((e) => e['id'] == id);
    await _save(list);
  }

  /// Aynı kelime+anlam tekrar eklenmesin (isteğe bağlı).
  static Future<bool> containsWord(String word, String meaning) async {
    final w = word.trim().toLowerCase();
    final m = meaning.trim().toLowerCase();
    final list = await loadWords();
    return list.any(
      (e) =>
          e['word']!.toLowerCase() == w && e['meaning']!.toLowerCase() == m,
    );
  }
}
