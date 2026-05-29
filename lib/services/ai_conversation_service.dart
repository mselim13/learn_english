import 'gemini_service.dart';
import 'local_english_partner.dart';

/// İngilizce konuşma asistanı.
///
/// Öncelik sırası:
///   1. Gemini API (backend proxy — bulut)
///   2. Şablon tabanlı yerel yanıtlar (internet yoksa yedek)
class AiConversationService {
  AiConversationService._();

  static const systemPrompt = '''
You are a warm conversation partner for a Turkish person learning English.

CRITICAL: Reply in English only.

Rules:
- Do not include Turkish.
- Do not prefix lines with "EN:" or "TR:".
- If the user writes in Turkish, respond in simple, friendly English and keep it short.
- Stay concise unless the user asks for more detail.''';

  /// Kullanılan backend bilgisini de döndürür: 'gemini' | 'local'
  /// [failReason] Gemini başarısız olduğunda sebebi taşır.
  static Future<({String text, String backend, String? failReason})> completeWithSource(
    List<Map<String, String>> messages,
  ) async {
    // 1. Gemini API (bulut)
    final geminiResult = await GeminiService.chatWithReason(messages);
    if (geminiResult.text != null && geminiResult.text!.isNotEmpty) {
      return (text: geminiResult.text!, backend: 'gemini', failReason: null);
    }

    // 2. Şablon yanıtlar (Gemini ulaşılamaz ise yedek)
    final withSystem = [
      {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];
    final text = LocalEnglishPartner.generateReply(withSystem);
    return (text: text, backend: 'local', failReason: geminiResult.failReason);
  }

  static Future<String> complete(List<Map<String, String>> messages) async {
    final r = await completeWithSource(messages);
    return r.text;
  }
}
