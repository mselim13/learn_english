import 'dart:io';

import 'package:llm_llamacpp/llm_llamacpp.dart';
import 'package:path_provider/path_provider.dart';

/// Çevrimdışı GGUF (llama.cpp / Ollama ile uyumlu kaynaklardan indirilen dosyalar) sohbet.
///
/// **Model dosyası** (sen seçeceğin instruct GGUF, örn. fine-tune sonrası):
/// 1. Uygulama bellek klasörüne `chat_model.gguf` adıyla kopyala, veya
/// 2. Derlemede `--dart-define=CHAT_GGUF_PATH=/tam/yol/model.gguf`
///
/// Önerilen başlangıç tabanı (dataset ile LoRA fine-tune edip birleştirebilirsin):
/// `Qwen2.5-0.5B-Instruct` veya `Llama-3.2-1B-Instruct` GGUF (Q4_K_M).
class OfflineLlamaService {
  OfflineLlamaService._();

  static const defaultModelFileName = 'chat_model.gguf';

  static LlamaCppChatRepository? _repo;
  static String? _loadedPath;

  /// Yerel dosya var mı (yüklenmiş olması gerekmez).
  static Future<bool> hasLocalModelFile() async {
    final p = await resolveModelPath();
    return p != null;
  }

  static Future<String?> resolveModelPath() async {
    const fromEnv = String.fromEnvironment('CHAT_GGUF_PATH', defaultValue: '');
    if (fromEnv.isNotEmpty) {
      final f = File(fromEnv);
      if (await f.exists()) return f.path;
    }
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/$defaultModelFileName');
    if (await f.exists()) return f.path;
    return null;
  }

  static Future<void> unload() async {
    _repo?.dispose();
    _repo = null;
    _loadedPath = null;
  }

  static Future<LlamaCppChatRepository> _ensureRepo(String path) async {
    if (_repo != null && _loadedPath == path) return _repo!;
    await unload();
    _loadedPath = path;
    _repo = LlamaCppChatRepository.withModelPath(
      path,
      contextSize: 2048,
      nGpuLayers: 0,
    );
    return _repo!;
  }

  static List<LLMMessage> _toLlmMessages(List<Map<String, String>> messages) {
    final out = <LLMMessage>[];
    for (final m in messages) {
      final text = (m['content'] ?? '').trim();
      if (text.isEmpty) continue;
      final roleStr = m['role'] ?? 'user';
      final role = switch (roleStr) {
        'system' => LLMRole.system,
        'assistant' => LLMRole.assistant,
        _ => LLMRole.user,
      };
      out.add(LLMMessage(role: role, content: text));
    }
    return out;
  }

  /// Son [maxMessages] mesaj (system varsa korunur).
  static List<Map<String, String>> trimMessages(
    List<Map<String, String>> messages, {
    int maxMessages = 20,
  }) {
    if (messages.isEmpty) return messages;
    final out = <Map<String, String>>[];
    var start = 0;
    if (messages.first['role'] == 'system') {
      out.add(Map<String, String>.from(messages.first));
      start = 1;
    }
    final tail = messages.sublist(start);
    if (tail.length > maxMessages) {
      out.addAll(
        tail.sublist(tail.length - maxMessages).map(Map<String, String>.from),
      );
    } else {
      out.addAll(tail.map(Map<String, String>.from));
    }
    return out;
  }

  /// GGUF yüklü ve çıktı üretildiyse metin; aksi halde boş string (çağıran yedekler).
  static Future<String> generate(List<Map<String, String>> messages) async {
    final path = await resolveModelPath();
    if (path == null) return '';

    final trimmed = trimMessages(messages);
    final llmMsgs = _toLlmMessages(trimmed);
    if (llmMsgs.isEmpty) return '';

    final repo = await _ensureRepo(path);
    final response = await repo.chatResponse(
      'local',
      messages: llmMsgs,
    );
    return (response.content ?? '').trim();
  }
}
