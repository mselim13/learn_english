import 'local_english_partner.dart';
import 'offline_llama_service.dart';

/// Offline English chat.
///
/// - If a local GGUF model exists: uses llama.cpp via [OfflineLlamaService]
/// - Otherwise: uses lightweight on-device templates via [LocalEnglishPartner]
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

  /// [backend]: `llama` | `local`
  static Future<({String text, String backend})> completeWithSource(
    List<Map<String, String>> messages,
  ) async {
    final withSystem = [
      {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];

    final hasModel = await OfflineLlamaService.hasLocalModelFile();
    if (hasModel) {
      try {
        final text = await OfflineLlamaService.generate(withSystem);
        if (text.isNotEmpty) return (text: text, backend: 'llama');
      } catch (_) {
        // fall through
      }
    }

    final text = LocalEnglishPartner.generateReply(withSystem);
    return (text: text, backend: 'local');
  }

  static Future<String> complete(List<Map<String, String>> messages) async {
    final r = await completeWithSource(messages);
    return r.text;
  }
}
