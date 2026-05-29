# LinguaAI — Feature List

## Mevcut Özellikler

### Kimlik & Oturum
- [x] Kayıt ol (ad, e-posta, şifre)
- [x] Giriş yap (e-posta + şifre)
- [x] Beni hatırla
- [x] Güvenli çıkış
- [x] Hesap silme
- [x] JWT oturum yönetimi (access + refresh token)
- [x] Otomatik token yenileme

### Kullanıcı Profili
- [x] Profil görüntüleme (ad, e-posta, seviye, üyelik tarihi)
- [x] Profil düzenleme
- [x] Avatar yükleme & kırpma
- [x] Şifre değiştirme (ekran hazır)
- [x] Seviye seçimi (A1–C2)

### Yerleştirme Testi
- [x] Onboarding akışı
- [x] Seviye belirleme testi
- [x] Test sonucu kaydetme

### Kelime Defteri
- [x] Kelime ekleme (kelime, anlam, örnek cümle)
- [x] Kelime listeleme
- [x] Kelime silme
- [x] Kelime detayı
- [x] **MongoDB'de kullanıcı başına saklama**

### AI Konuşma
- [x] İngilizce konuşma partneri
- [x] **Gemini API entegrasyonu** (bulut — öncelikli)
- [x] LlamaCPP offline yedek (GGUF modeli varsa)
- [x] Şablon tabanlı yerel yedek
- [x] Backend: 'gemini' | 'llama' | 'local' göstergesi

### İstatistikler
- [x] Günlük/haftalık/aylık çalışma grafikleri
- [x] Streak takibi
- [x] Beceri gelişim çubukları (Vocabulary, Listening, Speaking, Writing)
- [x] Seviye ilerleme çubuğu
- [x] Rozetler (7 gün seri, 50 kelime, 1 saat dinleme)
- [x] **Backend senkronizasyonu** (çalışma dakikaları MongoDB'ye yazılır)

### Quiz & Alıştırma
- [x] Kelime quizi
- [x] Sonuç sayfası
- [x] Flash kartlar

### Dinleme & Konuşma
- [x] Metin okuma (TTS)
- [x] Konuşma tanıma (STT)
- [x] Dinleme egzersizi sayfası

### Çeviri
- [x] Sözlük tabanlı çeviri (offline)
- [x] Kelime arama

### Ayarlar & Bildirimler
- [x] Karanlık mod tercihi
- [x] Günlük çalışma hedefi
- [x] Günlük hatırlatıcı bildirimleri
- [x] Ses efektleri açma/kapama
- [x] Bildirim ayarları

### Altyapı & Güvenlik
- [x] Node.js / Express REST API backend
- [x] MongoDB Atlas veritabanı
- [x] Helmet güvenlik başlıkları
- [x] NoSQL injection koruması (express-mongo-sanitize)
- [x] Rate limiting (brute-force önleme)
- [x] JWT access + refresh token mimarisi
- [x] Payload boyutu kısıtlaması (50 KB)

---

## Planlanan Özellikler

### Kısa Vadeli
- [ ] Şifremi unuttum (e-posta ile sıfırlama)
- [ ] Google / Apple ile giriş (OAuth)
- [ ] Kelime defteri filtreleme & arama
- [ ] Hata bildir / Geri bildirim formu
- [ ] Profil sayfasında üyelik süresi rozeti

### Orta Vadeli
- [ ] Gemini API: kelime açıklaması üretme
- [ ] Gemini API: örnek cümle üretme
- [ ] Push notification (FCM)
- [ ] Çoklu dil desteği (İspanyolca, Almanca…)
- [ ] Liderlik tablosu (streak sıralaması)
- [ ] Sosyal paylaşım (rozet paylaşma)

### Uzun Vadeli
- [ ] Canlı öğretmen bağlantısı
- [ ] Kişiselleştirilmiş öğrenme planı (AI tabanlı)
- [ ] Video ders entegrasyonu
- [ ] IELTS / TOEFL alıştırma modülü
- [ ] Offline tam özellik (tam sync)
- [ ] Web panel (admin dashboard)

---

## AI Araçları

| Araç | Kullanım | Konum |
|------|----------|-------|
| **Gemini 1.5 Flash** | Konuşma partneri (öncelikli) | Backend proxy (`/api/ai/chat`) |
| **LlamaCPP (GGUF)** | Offline konuşma yedek | Cihaz üzerinde (`third_party/llm_llamacpp`) |
| **Şablon sistemi** | Her zaman çalışan yedek | `local_english_partner.dart` |

---

## Veritabanı Şeması (MongoDB)

### `users` koleksiyonu
```
_id, name, email, password (hash), level, membershipJoinedAt,
dailyGoalMinutes, placementTestCompleted, placementTestScore,
notificationsEnabled, dailyReminderEnabled, dailyReminderTimeMinutes,
soundEffectsEnabled, darkMode, refreshToken, createdAt, updatedAt
```

### `vocabularies` koleksiyonu
```
_id, userId (→ users), word, meaning, example, createdAt, updatedAt
```

### `userstats` koleksiyonu
```
_id, userId (→ users),
dailyMinutes: [{date, minutes}],
streak: {lastDay, count},
skills: {vocabulary, listening, speaking, writing},
levelProgress: Map<level, bps>,
badges: Map<id, bool>,
listeningTotalMinutes, weeklyGoalMinutes,
createdAt, updatedAt
```
