const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

function generateAccessToken(userId) {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
  });
}

function generateRefreshToken(userId) {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  });
}

// POST /api/auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Ad, e-posta ve parola zorunludur' });
    }
    if (password.length < 6) {
      return res.status(400).json({ message: 'Parola en az 6 karakter olmalıdır' });
    }

    const existing = await User.findOne({ email: email.trim().toLowerCase() });
    if (existing) {
      return res.status(409).json({ message: 'Bu e-posta adresi zaten kayıtlı' });
    }

    const hashed = await bcrypt.hash(password, 10);
    const user = await User.create({
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: hashed,
    });

    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);
    user.refreshToken = refreshToken;
    await user.save();

    res.status(201).json({ accessToken, refreshToken, user });
  } catch (err) {
    console.error('register:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'E-posta ve parola zorunludur' });
    }

    const user = await User.findOne({ email: email.trim().toLowerCase() }).select('+password');
    if (!user) {
      return res.status(401).json({ message: 'E-posta veya parola hatalı' });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ message: 'E-posta veya parola hatalı' });
    }

    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);
    user.refreshToken = refreshToken;
    await user.save();

    res.json({ accessToken, refreshToken, user });
  } catch (err) {
    console.error('login:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ message: 'Refresh token gerekli' });
    }

    let decoded;
    try {
      decoded = jwt.verify(refreshToken, process.env.JWT_SECRET);
    } catch {
      return res.status(401).json({ message: 'Geçersiz refresh token' });
    }

    const user = await User.findById(decoded.id);
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ message: 'Oturum geçersiz kılındı' });
    }

    const newAccessToken = generateAccessToken(user._id);
    res.json({ accessToken: newAccessToken });
  } catch (err) {
    console.error('refresh:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// POST /api/auth/logout  (kimlik doğrulama gerekli)
router.post('/logout', authMiddleware, async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.user.id, { refreshToken: null });
    res.json({ message: 'Çıkış yapıldı' });
  } catch (err) {
    console.error('logout:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// GET /api/auth/me
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'Kullanıcı bulunamadı' });
    res.json({ user });
  } catch (err) {
    console.error('me:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// PUT /api/auth/profile  (profil + ayarlar güncelleme)
router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const allowed = [
      'name', 'email', 'level', 'dailyGoalMinutes',
      'placementTestCompleted', 'placementTestScore',
      'notificationsEnabled', 'dailyReminderEnabled',
      'dailyReminderTimeMinutes', 'soundEffectsEnabled', 'darkMode',
    ];
    const updates = {};
    for (const key of allowed) {
      if (req.body[key] !== undefined) updates[key] = req.body[key];
    }

    if (updates.email) {
      updates.email = updates.email.trim().toLowerCase();
      const conflict = await User.findOne({
        email: updates.email,
        _id: { $ne: req.user.id },
      });
      if (conflict) {
        return res.status(409).json({ message: 'Bu e-posta başka hesapta kullanılıyor' });
      }
    }

    const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true });
    res.json({ user });
  } catch (err) {
    console.error('profile:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

// DELETE /api/auth/account
router.delete('/account', authMiddleware, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.user.id);
    res.json({ message: 'Hesap silindi' });
  } catch (err) {
    console.error('delete account:', err.message);
    res.status(500).json({ message: 'Sunucu hatası' });
  }
});

module.exports = router;
