import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'stats_store.dart';

/// Kelime defteri: kullanıcı başına MongoDB'de saklanır.
/// Ağ erişimi yoksa SharedPreferences önbelleğine düşer.
class VocabularyBookService {
  static const _cacheKey = 'vocabulary_book_json';

  // ── Yerel önbellek yardımcıları ────────────────────────────────

  static Future<List<Map<String, String>>> _loadFromCache() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_cacheKey);
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
          'exampleTr': m['exampleTr']?.toString() ?? '',
        };
      }).where((e) => e['word']!.isNotEmpty && e['meaning']!.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveToCache(List<Map<String, String>> words) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_cacheKey, jsonEncode(words));
  }

  static List<Map<String, String>> _mapWord(dynamic w) {
    final m = Map<String, dynamic>.from(w as Map);
    return [
      {
        'id': (m['_id'] ?? m['id'] ?? '').toString(),
        'word': m['word']?.toString() ?? '',
        'meaning': m['meaning']?.toString() ?? '',
        'example': m['example']?.toString() ?? '',
        'exampleTr': m['exampleTr']?.toString() ?? '',
      }
    ];
  }

  // ── Public API ─────────────────────────────────────────────────

  /// Kelimeleri yükle: önce API, başarısız olursa önbellek.
  static Future<List<Map<String, String>>> loadWords() async {
    try {
      final res = await ApiService.get('/vocab');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final words = (body['words'] as List<dynamic>)
            .expand(_mapWord)
            .where((e) => e['word']!.isNotEmpty)
            .toList();
        await _saveToCache(words);
        return words;
      }
    } catch (_) {}
    // API'ye ulaşılamadı — önbellekten yükle.
    return _loadFromCache();
  }

  /// Kelime ekle: API'ye gönder, önbelleği güncelle.
  static Future<void> addWord({
    required String word,
    required String meaning,
    String example = '',
    String exampleTr = '',
  }) async {
    final w = word.trim();
    final m = meaning.trim();
    if (w.isEmpty || m.isEmpty) return;

    try {
      final res = await ApiService.post('/vocab', {
        'word': w,
        'meaning': m,
        'example': example.trim(),
        'exampleTr': exampleTr.trim(),
      });

      if (res.statusCode == 201 || res.statusCode == 200) {
        // API başarılı — tam listeyi yeniden çek (önbelleği güncelle).
        await loadWords();
        await StatsStore.recomputeBadges();
        return;
      }
    } catch (_) {}

    // API'ye ulaşılamadı — yerel önbelleğe kaydet.
    final list = await _loadFromCache();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    list.add({
      'id': id,
      'word': w,
      'meaning': m,
      'example': example.trim(),
      'exampleTr': exampleTr.trim(),
    });
    await _saveToCache(list);
    await StatsStore.recomputeBadges();
  }

  /// Kelimeyi ID'ye göre sil.
  static Future<void> removeById(String id) async {
    if (id.isEmpty) return;

    try {
      await ApiService.delete('/vocab/$id');
    } catch (_) {}

    // Her durumda önbellekten de kaldır.
    final list = await _loadFromCache();
    list.removeWhere((e) => e['id'] == id);
    await _saveToCache(list);
    await StatsStore.recomputeBadges();
  }

  /// Aynı kelime+anlam çifti zaten var mı?
  static Future<bool> containsWord(String word, String meaning) async {
    final w = word.trim().toLowerCase();
    final m = meaning.trim().toLowerCase();
    final list = await _loadFromCache();
    return list.any(
      (e) =>
          e['word']!.toLowerCase() == w && e['meaning']!.toLowerCase() == m,
    );
  }
}
