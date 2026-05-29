const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

const SYSTEM_PROMPT = `You are a warm and encouraging conversation partner for a Turkish person learning English.

CRITICAL RULES:
- Always reply in English only.
- Never include Turkish text in your response.
- Keep replies concise (2-4 sentences) unless the user asks for more detail.
- If the user writes in Turkish, gently respond in simple English and guide them to practice in English.
- Do not prefix lines with "EN:" or "TR:".
- Be friendly, patient, and supportive.`;

// POST /api/ai/chat
router.post('/chat', async (req, res) => {
  try {
    const { messages } = req.body;

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ message: 'messages dizisi gerekli' });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.status(503).json({ message: 'Gemini API anahtarı yapılandırılmamış' });
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      systemInstruction: SYSTEM_PROMPT,
    });

    // Flutter'dan gelen messages [{role, content}] formatını Gemini formatına dönüştür.
    const rawHistory = messages.slice(0, -1).map((m) => ({
      role: m.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: m.content }],
    }));

    // Gemini history 'user' rolüyle başlamak zorunda.
    // UI'daki ilk AI karşılama mesajı gibi başta gelen 'model' satırlarını at.
    const firstUserIdx = rawHistory.findIndex((m) => m.role === 'user');
    const history = firstUserIdx >= 0 ? rawHistory.slice(firstUserIdx) : [];

    const lastMessage = messages[messages.length - 1];
    const chat = model.startChat({ history });
    const result = await chat.sendMessage(lastMessage.content);
    const text = result.response.text();

    res.json({ text });
  } catch (err) {
    console.error('ai/chat:', err.message);
    res.status(500).json({ message: 'AI yanıtı alınamadı', error: err.message });
  }
});

// POST /api/ai/translate
router.post('/translate', async (req, res) => {
  try {
    const { text } = req.body;

    if (!text || typeof text !== 'string' || text.trim().length === 0) {
      return res.status(400).json({ message: 'text alanı gerekli' });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.status(503).json({ message: 'Gemini API anahtarı yapılandırılmamış' });
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const prompt = `You are an English-Turkish dictionary assistant. The user entered: "${text.trim()}"

Reply ONLY in this exact JSON format (no markdown, no extra text):
{
  "translation": "<Turkish translation>",
  "partOfSpeech": "<noun/verb/adjective/phrase/etc. in Turkish: isim/fiil/sıfat/deyim/etc.>",
  "example": "<one natural English example sentence using the word/phrase>",
  "exampleTr": "<Turkish translation of the example sentence>"
}`;

    const result = await model.generateContent(prompt);
    let raw = result.response.text().trim();

    // Bazen Gemini ```json ... ``` şeklinde sarar, temizle.
    raw = raw.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim();

    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch {
      // JSON parse başarısız olursa ham metni döndür.
      return res.json({ translation: raw, partOfSpeech: null, example: null, exampleTr: null });
    }

    res.json(parsed);
  } catch (err) {
    console.error('ai/translate:', err.message);
    res.status(500).json({ message: 'Çeviri yapılamadı', error: err.message });
  }
});

// POST /api/ai/quiz  — seviyeye göre quiz soruları üret
router.post('/quiz', async (req, res) => {
  try {
    const { level = 'A2', category = 'Kelime', count = 8 } = req.body;

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.status(503).json({ message: 'Gemini API anahtarı yapılandırılmamış' });
    }

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const prompt = `Generate ${count} English vocabulary multiple-choice questions for a ${level} level English learner.
Category: ${category}

Reply ONLY with a valid JSON array (no markdown, no extra text):
[
  {
    "word": "<English word or phrase>",
    "options": ["<Turkish option 1>", "<Turkish option 2>", "<Turkish option 3>", "<Turkish option 4>"],
    "correct": <0-3 index of correct Turkish meaning>
  }
]

Rules:
- All 4 options must be Turkish translations/meanings
- Vary the correct index (not always 0)
- Words must match ${level} CEFR level
- No repeated words
- Make wrong options plausible but clearly incorrect`;

    const result = await model.generateContent(prompt);
    let raw = result.response.text().trim();

    // Markdown kod bloğunu temizle
    raw = raw.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim();

    let questions;
    try {
      questions = JSON.parse(raw);
      if (!Array.isArray(questions)) throw new Error('Dizi değil');
    } catch {
      return res.status(500).json({ message: 'AI yanıtı parse edilemedi', raw });
    }

    res.json({ questions });
  } catch (err) {
    console.error('ai/quiz:', err.message);
    res.status(500).json({ message: 'Quiz oluşturulamadı', error: err.message });
  }
});

// POST /api/ai/prompt — yazma/konuşma pratiği için konu bazlı görev üret
router.post('/prompt', async (req, res) => {
  try {
    const { level = 'A2', topic = 'Introduce yourself', mode = 'writing' } = req.body;

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) return res.status(503).json({ message: 'Gemini API anahtarı yapılandırılmamış' });

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const modeInstruction = mode === 'speaking'
      ? 'a speaking practice task (ask the student to speak about something)'
      : 'a writing practice task (ask the student to write about something)';

    const prompt = `Create ${modeInstruction} for a ${level} CEFR level English learner.
Topic hint: "${topic}"

Reply with ONLY the task instruction in English (1-2 sentences). No preamble, no labels, no explanation.
Example: "Tell me about your favorite food and why you enjoy it."`;

    const result = await model.generateContent(prompt);
    const text = result.response.text().trim();
    res.json({ prompt: text });
  } catch (err) {
    console.error('ai/prompt:', err.message);
    res.status(500).json({ message: 'Prompt oluşturulamadı', error: err.message });
  }
});

// POST /api/ai/evaluate — kullanıcı yazma/konuşma yanıtını değerlendir
router.post('/evaluate', async (req, res) => {
  try {
    const { level = 'A2', topic = '', userResponse = '', mode = 'writing' } = req.body;

    if (!userResponse || userResponse.trim().length === 0) {
      return res.status(400).json({ message: 'userResponse boş olamaz' });
    }

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) return res.status(503).json({ message: 'Gemini API anahtarı yapılandırılmamış' });

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const prompt = `You are an encouraging English language teacher evaluating a ${level} CEFR level student's ${mode} practice.

Task given to student: "${topic}"
Student's response: "${userResponse.trim()}"

Evaluate and reply ONLY in this exact JSON format (no markdown, no extra text):
{
  "score": <integer 0-100>,
  "feedback": "<2-3 sentences of encouraging English feedback: mention what was good and one specific thing to improve>",
  "feedbackTr": "<Turkish translation of the feedback>"
}

Scoring guide: 80-100 = excellent for ${level}, 60-79 = good with minor errors, 40-59 = understandable but needs work, 0-39 = mostly in wrong language or incomprehensible.
If the response is in Turkish rather than English, score ≤ 30 and encourage English practice.`;

    const result = await model.generateContent(prompt);
    let raw = result.response.text().trim();
    raw = raw.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim();

    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch {
      return res.status(500).json({ message: 'AI yanıtı parse edilemedi', raw });
    }

    res.json(parsed);
  } catch (err) {
    console.error('ai/evaluate:', err.message);
    res.status(500).json({ message: 'Değerlendirme yapılamadı', error: err.message });
  }
});

// POST /api/ai/listening — dinleme dikte alıştırması için cümleler üret
router.post('/listening', async (req, res) => {
  try {
    const { level = 'A2', count = 3 } = req.body;

    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) return res.status(503).json({ message: 'Gemini API anahtarı yapılandırılmamış' });

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const prompt = `Generate ${count} English sentences for a listening dictation exercise at ${level} CEFR level.

Reply ONLY with a valid JSON array of strings (no markdown, no extra text):
["sentence 1", "sentence 2", "sentence 3"]

Rules:
- Sentences must match ${level} difficulty (simple vocabulary and grammar)
- Natural, conversational English
- 5-12 words per sentence
- No repeated vocabulary between sentences
- Varied topics (daily life, greetings, activities, etc.)`;

    const result = await model.generateContent(prompt);
    let raw = result.response.text().trim();
    raw = raw.replace(/^```json\s*/i, '').replace(/^```\s*/i, '').replace(/```$/i, '').trim();

    let sentences;
    try {
      sentences = JSON.parse(raw);
      if (!Array.isArray(sentences)) throw new Error('Dizi değil');
    } catch {
      return res.status(500).json({ message: 'AI yanıtı parse edilemedi', raw });
    }

    res.json({ sentences });
  } catch (err) {
    console.error('ai/listening:', err.message);
    res.status(500).json({ message: 'Listening cümleleri oluşturulamadı', error: err.message });
  }
});

module.exports = router;
