const express = require('express');
const Vocabulary = require('../models/Vocabulary');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Tüm rotalar kimlik doğrulama gerektirir.
router.use(authMiddleware);

// GET /api/vocab  — kullanıcının tüm kelimeleri
router.get('/', async (req, res) => {
  try {
    const words = await Vocabulary.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json({ words });
  } catch (err) {
    console.error('vocab GET:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// POST /api/vocab  — kelime ekle
router.post('/', async (req, res) => {
  try {
    const { word, meaning, example = '', exampleTr = '' } = req.body;

    if (!word || !meaning) {
      return res.status(400).json({ message: 'Kelime ve anlam zorunludur' });
    }

    const trimWord = word.trim();
    const trimMeaning = meaning.trim();

    // Aynı kelime+anlam çifti zaten varsa hata dönme, mevcut kaydı döndür.
    const existing = await Vocabulary.findOne({
      userId: req.user.id,
      word: { $regex: new RegExp(`^${trimWord}$`, 'i') },
      meaning: { $regex: new RegExp(`^${trimMeaning}$`, 'i') },
    });

    if (existing) {
      return res.status(200).json({ word: existing, duplicate: true });
    }

    const vocab = await Vocabulary.create({
      userId: req.user.id,
      word: trimWord,
      meaning: trimMeaning,
      example: example.trim(),
      exampleTr: exampleTr.trim(),
    });

    res.status(201).json({ word: vocab });
  } catch (err) {
    console.error('vocab POST:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// DELETE /api/vocab/:id  — kelime sil
router.delete('/:id', async (req, res) => {
  try {
    const vocab = await Vocabulary.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.id,
    });

    if (!vocab) {
      return res.status(404).json({ message: 'Kelime bulunamadı' });
    }

    res.json({ message: 'Kelime silindi' });
  } catch (err) {
    console.error('vocab DELETE:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

module.exports = router;
