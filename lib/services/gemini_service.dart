import 'dart:convert';
import 'dart:developer' as dev;

import 'api_service.dart';

/// Gemini API ile İngilizce konuşma partneri.
/// İstekler güvenli şekilde backend proxy üzerinden iletilir.
class GeminiService {
  GeminiService._();

  /// messages: [{role: 'user'|'assistant', content: '...'}]
  /// Başarılı olursa yanıt metnini, hata durumunda null döner.
  /// [failReason] neden null döndüğünü açıklar (debug için).
  static Future<({String? text, String? failReason})> chatWithReason(
    List<Map<String, String>> messages,
  ) async {
    try {
      final res = await ApiService.post('/ai/chat', {'messages': messages});
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final text = body['text'] as String?;
        return (text: text, failReason: null);
      }
      // 4xx / 5xx — backend erişilebilir ama hata döndü
      String reason;
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final msg = body['message']?.toString() ?? '';
        final err = body['error']?.toString() ?? '';
        reason = [
          'HTTP ${res.statusCode}',
          if (msg.isNotEmpty) msg,
          if (err.isNotEmpty) err,
        ].join(' — ');
      } catch (_) {
        reason = 'HTTP ${res.statusCode}';
      }
      dev.log('[GeminiService.chat] $reason', name: 'AI');
      return (text: null, failReason: reason);
    } catch (e) {
      // Ağ hatası, timeout vb.
      final reason = e.runtimeType.toString().contains('Timeout')
          ? 'Backend\'e bağlanılamadı (timeout)'
          : 'Ağ hatası: ${e.runtimeType}';
      dev.log('[GeminiService.chat] $reason', name: 'AI');
      return (text: null, failReason: reason);
    }
  }

  /// Geriye dönük uyumluluk için.
  static Future<String?> chat(List<Map<String, String>> messages) async {
    final r = await chatWithReason(messages);
    return r.text;
  }

  /// AI ile quiz soruları üretir.
  /// [{word, options:[String], correct:int}] listesi döner, hata durumunda null.
  static Future<List<Map<String, dynamic>>?> generateQuiz({
    required String level,
    String category = 'Kelime',
    int count = 8,
  }) async {
    try {
      final res = await ApiService.post('/ai/quiz', {
        'level': level,
        'category': category,
        'count': count,
      });
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = body['questions'] as List<dynamic>;
        return raw.map((q) {
          final m = q as Map<String, dynamic>;
          return {
            'word': m['word']?.toString() ?? '',
            'options': (m['options'] as List<dynamic>).map((o) => o.toString()).toList(),
            'correct': (m['correct'] as num).toInt(),
          };
        }).toList();
      }
      dev.log('[GeminiService.generateQuiz] HTTP ${res.statusCode}: ${res.body.substring(0, 100)}', name: 'AI');
    } catch (e) {
      dev.log('[GeminiService.generateQuiz] $e', name: 'AI');
    }
    return null;
  }

  /// Yazma/konuşma pratiği için AI prompt üretir.
  /// Hata durumunda null döner.
  static Future<String?> generatePrompt({
    required String level,
    required String topic,
    required String mode,
  }) async {
    try {
      final res = await ApiService.post('/ai/prompt', {
        'level': level,
        'topic': topic,
        'mode': mode,
      });
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return body['prompt'] as String?;
      }
      dev.log('[GeminiService.generatePrompt] HTTP ${res.statusCode}', name: 'AI');
    } catch (e) {
      dev.log('[GeminiService.generatePrompt] $e', name: 'AI');
    }
    return null;
  }

  /// Kullanıcının yazma/konuşma yanıtını değerlendirir.
  /// {score: int, feedback: String, feedbackTr: String} döner, hata durumunda null.
  static Future<Map<String, dynamic>?> evaluateResponse({
    required String level,
    required String topic,
    required String userResponse,
    required String mode,
  }) async {
    try {
      final res = await ApiService.post('/ai/evaluate', {
        'level': level,
        'topic': topic,
        'userResponse': userResponse,
        'mode': mode,
      });
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'score': (body['score'] as num).toInt(),
          'feedback': body['feedback'] as String? ?? '',
          'feedbackTr': body['feedbackTr'] as String? ?? '',
        };
      }
      dev.log('[GeminiService.evaluateResponse] HTTP ${res.statusCode}', name: 'AI');
    } catch (e) {
      dev.log('[GeminiService.evaluateResponse] $e', name: 'AI');
    }
    return null;
  }

  /// Dinleme dikte alıştırması için AI cümleleri üretir.
  /// Hata durumunda null döner.
  static Future<List<String>?> generateListeningSentences({
    required String level,
    int count = 3,
  }) async {
    try {
      final res = await ApiService.post('/ai/listening', {
        'level': level,
        'count': count,
      });
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = body['sentences'] as List<dynamic>;
        return raw.map((s) => s.toString()).toList();
      }
      dev.log('[GeminiService.generateListeningSentences] HTTP ${res.statusCode}', name: 'AI');
    } catch (e) {
      dev.log('[GeminiService.generateListeningSentences] $e', name: 'AI');
    }
    return null;
  }

  /// İngilizce → Türkçe çeviri.
  /// Dönen map: {translation, partOfSpeech, example, exampleTr}
  /// Hata durumunda null döner.
  static Future<Map<String, String?>?> translate(String text) async {
    try {
      final res = await ApiService.post('/ai/translate', {'text': text});
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return {
          'translation': body['translation'] as String?,
          'partOfSpeech': body['partOfSpeech'] as String?,
          'example': body['example'] as String?,
          'exampleTr': body['exampleTr'] as String?,
        };
      }
    } catch (_) {}
    return null;
  }
}
