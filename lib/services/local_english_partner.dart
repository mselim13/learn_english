import 'dart:math';

/// Ücretsiz, tamamen cihaz içi yanıtlar — her mesaj EN + TR (harici API yok).
class LocalEnglishPartner {
  LocalEnglishPartner._();

  static final _rand = Random();

  static String _both(String en, String tr) => 'EN: $en\nTR: $tr';

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
        _both(
          "I'm listening — what would you like to talk about?",
          "Dinliyorum — ne hakkında konuşmak istersin?",
        ),
        _both(
          "Tell me about your day or ask me anything!",
          "Bana gününden bahset ya da istediğini sor!",
        ),
      ]);
    }

    final lower = lastUser.toLowerCase();
    final hasTurkish = RegExp(r'[ğüşıöçĞÜŞİÖÇİı]').hasMatch(lastUser);

    if (hasTurkish) {
      return _pick([
        _both(
          "Nice — I understood you. Let's say the same idea in one simple English sentence too, and I'll help you polish it.",
          "Güzel, anladım. Aynı düşünceyi bir de basit bir İngilizce cümleyle söylemeyi dene, birlikte düzeltiriz.",
        ),
        _both(
          "Good message! Try translating one short phrase into English — even basic words are fine.",
          "Güzel mesaj! Kısa bir ifadeyi İngilizceye çevirmeyi dene — basit kelimeler de olur.",
        ),
        _both(
          "I get it. Pick one sentence from what you wrote and say it in English — step by step is okay.",
          "Anladım. Yazdıklarından bir cümleyi seçip İngilizce söyle — adım adım olur.",
        ),
      ]);
    }

    if (RegExp(r'^(hi|hello|hey|good morning|good afternoon|good evening)[\s!.?]*$', caseSensitive: false).hasMatch(lower)) {
      return _pick([
        _both(
          "Hey! Great to chat. What's something fun you did recently?",
          "Merhaba! Sohbet güzel. Son zamanlarda eğlenceli bir şey yaptın mı?",
        ),
        _both(
          "Hello! What topic do you want to practice today?",
          "Selam! Bugün hangi konuda pratik yapmak istersin?",
        ),
        _both(
          "Hi! Tell me about your weekend in two or three English sentences.",
          "Merhaba! Hafta sonunu iki üç İngilizce cümleyle anlat.",
        ),
      ]);
    }

    if (lower.contains('how are you') || lower == "how's it going" || lower.contains('how is it going')) {
      return _pick([
        _both(
          "I'm doing well, thanks! How about you — one good thing about your week?",
          "İyiyim, teşekkürler! Sen nasılsın — bu hafta güzel olan bir şey?",
        ),
        _both(
          "All good here! How are you feeling today?",
          "Burada her şey yolunda! Bugün nasıl hissediyorsun?",
        ),
      ]);
    }

    if (lower.contains('thank') || lower == 'thanks' || lower == 'ty') {
      return _pick([
        _both(
          "You're welcome! What's next on your mind?",
          "Rica ederim! Aklında başka ne var?",
        ),
        _both(
          "Anytime! Ask me another question to keep the chat going.",
          "Ne demek! Sohbeti sürdürmek için bana başka bir soru sor.",
        ),
      ]);
    }

    if (RegExp(r'\b(bye|goodbye|see you|gotta go)\b').hasMatch(lower)) {
      return _pick([
        _both(
          "See you! A little practice every day really helps.",
          "Görüşürüz! Her gün kısa pratik çok işe yarar.",
        ),
        _both(
          "Take care! Try one English sentence about your plans for tomorrow.",
          "Kendine iyi bak! Yarınki planların için bir İngilizce cümle kurmayı dene.",
        ),
      ]);
    }

    if (lastUser.contains('?')) {
      return _pick([
        _both(
          "That's a good question. In casual English, keep it short and clear — what do you most want to know?",
          "Güzel soru. Günlük İngilizcede kısa ve net ol — en çok neyi öğrenmek istiyorsun?",
        ),
        _both(
          "Nice! Everyday questions are often simple and direct — try saying the main point in one line.",
          "Güzel! Günlük sorular genelde basit ve doğrudan — ana mesajı tek satırda söylemeyi dene.",
        ),
        _both(
          "I like that you asked. Try answering it yourself in one sentence — it builds confidence.",
          "Sormana sevindim. Önce kendi cümlelerinle cevaplamayı dene — özgüven verir.",
        ),
      ]);
    }

    if (lower.split(RegExp(r'\s+')).length <= 2 &&
        RegExp(r'^(yes|no|ok|okay|sure|maybe|idk|i do not know)\b', caseSensitive: false)
            .hasMatch(lower)) {
      return _pick([
        _both(
          "Got it! Can you add a bit more — maybe why you feel that way?",
          "Anladım! Biraz daha ekleyebilir misin — mesela neden böyle düşündüğünü?",
        ),
        _both(
          "Thanks! Turn that into a full sentence in English.",
          "Teşekkürler! Bunu tam bir İngilizce cümleye çevir.",
        ),
      ]);
    }

    if (lower.contains('help') && lower.contains('english')) {
      return _pick([
        _both(
          "I'm here for that! Pick a situation — ordering food, small talk, or email — and we'll practice short phrases.",
          "Buradayım! Bir durum seç — yemek siparişi, sohbet veya e-posta — kısa kalıplar çalışalım.",
        ),
        _both(
          "Sure. Tell me beginner or intermediate, and one place you need English.",
          "Tamam. Bana başlangıç mı orta seviye mi söyle ve İngilizceye nerede ihtiyacın olduğunu yaz.",
        ),
      ]);
    }

    final snippet = lastUser.length > 80 ? '${lastUser.substring(0, 77)}...' : lastUser;
    return _pick([
      _both(
        "Thanks for sharing — I follow you. What happened next? Tell me step by step.",
        "Paylaştığın için teşekkürler — takip ettim. Sonra ne oldu? Adım adım anlat.",
      ),
      _both(
        "Nice detail! \"$snippet\" — if you gave it an English title, what would it be?",
        "Güzel ayrıntı! \"$snippet\" — buna İngilizce bir başlık verseydin ne olurdu?",
      ),
      _both(
        "Interesting! Ask me a follow-up question in English to keep the conversation going.",
        "İlginç! Sohbeti sürdürmek için bana İngilizce takip sorusu sor.",
      ),
      _both(
        "Good job. Try summarizing your message in one shorter English sentence.",
        "Aferin. Mesajını daha kısa tek bir İngilizce cümleyle özetlemeyi dene.",
      ),
      _both(
        "I see. What would you tell a friend in English if you said the same thing?",
        "Anladım. Aynı şeyi bir arkadaşına İngilizce nasıl söylerdin?",
      ),
    ]);
  }

  static String _pick(List<String> options) => options[_rand.nextInt(options.length)];
}
