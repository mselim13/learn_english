const express = require('express');
const UserStats = require('../models/UserStats');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

router.use(authMiddleware);

// GET /api/stats  — kullanıcının istatistikleri
router.get('/', async (req, res) => {
  try {
    const stats = await UserStats.findOne({ userId: req.user.id });
    if (!stats) {
      return res.json({ stats: null });
    }
    res.json({ stats });
  } catch (err) {
    console.error('stats GET:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// PUT /api/stats  — istatistikleri tam olarak güncelle (Flutter cihazdan senkronize eder)
router.put('/', async (req, res) => {
  try {
    const {
      dailyMinutes,
      streak,
      skills,
      levelProgress,
      badges,
      listeningTotalMinutes,
      weeklyGoalMinutes,
    } = req.body;

    const update = {};
    if (dailyMinutes !== undefined) update.dailyMinutes = dailyMinutes;
    if (streak !== undefined) update.streak = streak;
    if (skills !== undefined) update.skills = skills;
    if (levelProgress !== undefined) update.levelProgress = levelProgress;
    if (badges !== undefined) update.badges = badges;
    if (listeningTotalMinutes !== undefined) update.listeningTotalMinutes = listeningTotalMinutes;
    if (weeklyGoalMinutes !== undefined) update.weeklyGoalMinutes = weeklyGoalMinutes;

    const stats = await UserStats.findOneAndUpdate(
      { userId: req.user.id },
      { $set: update },
      { new: true, upsert: true }
    );

    res.json({ stats });
  } catch (err) {
    console.error('stats PUT:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// POST /api/stats/study  — tek bir çalışma seansını kaydet
router.post('/study', async (req, res) => {
  try {
    const { date, minutes } = req.body;

    if (!date || !minutes || minutes <= 0) {
      return res.status(400).json({ message: 'date ve minutes zorunludur' });
    }

    // Varsa o günün dakikasını artır, yoksa yeni giriş ekle.
    const existing = await UserStats.findOne({
      userId: req.user.id,
      'dailyMinutes.date': date,
    });

    let stats;
    if (existing) {
      stats = await UserStats.findOneAndUpdate(
        { userId: req.user.id, 'dailyMinutes.date': date },
        { $inc: { 'dailyMinutes.$.minutes': minutes } },
        { new: true }
      );
    } else {
      stats = await UserStats.findOneAndUpdate(
        { userId: req.user.id },
        { $push: { dailyMinutes: { date, minutes } } },
        { new: true, upsert: true }
      );
    }

    res.json({ stats });
  } catch (err) {
    console.error('stats/study POST:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

module.exports = router;
