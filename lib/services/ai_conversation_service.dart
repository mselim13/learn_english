import 'offline_llama_service.dart';
import 'local_english_partner.dart';

/// İngilizce sohbet: çevrimdışı **GGUF** (llm_llamacpp) → yoksa / hata → **yerel şablon**.
class AiConversationService {
  AiConversationService._();

  static const systemPrompt = '''
You are a warm conversation partner for a Turkish person learning English.

CRITICAL: Every single reply MUST be bilingual. Use exactly this format (two lines, always both):

EN: [natural English — 1 to 3 short sentences]
TR: [same meaning in natural Turkish — 1 to 3 short sentences]

Rules:
- Never answer in only English or only Turkish; always include both EN: and TR: lines.
- If the user writes in Turkish or English, still reply with both languages.
- Keep the same ideas in EN and TR; do not lecture — sound like a friendly chat.
- Stay concise unless the user asks for more detail.''';

  static Future<String> _localReply(List<Map<String, String>> messages) async {
    await Future<void>.delayed(Duration(milliseconds: 280 + _hashDelay(messages)));
    return LocalEnglishPartner.generateReply(messages);
  }

  /// [backend]: `llama` | `local`
  static Future<({String text, String backend})> completeWithSource(
    List<Map<String, String>> messages,
  ) async {
    final hasFile = await OfflineLlamaService.hasLocalModelFile();
    if (hasFile) {
      try {
        final text = await OfflineLlamaService.generate(messages);
        if (text.isNotEmpty) {
          return (text: text, backend: 'llama');
        }
      } catch (_) {}
    }
    final text = await _localReply(messages);
    return (text: text, backend: 'local');
  }

  static Future<String> complete(List<Map<String, String>> messages) async {
    final r = await completeWithSource(messages);
    return r.text;
  }

  static int _hashDelay(List<Map<String, String>> messages) {
    var h = 0;
    for (final m in messages) {
      for (final c in (m['content'] ?? '').codeUnits) {
        h = (h * 31 + c) & 0x3ff;
      }
    }
    return h % 400;
  }
}
