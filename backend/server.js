require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const rateLimit = require('express-rate-limit');
const connectDB = require('./config/db');

const app = express();

// ── Veritabanı bağlantısı + migration ────────────────────────────
connectDB()
  .then(() => _runMigrations())
  .catch((err) => {
    console.error('MongoDB bağlantı hatası:', err.message);
    process.exit(1);
  });

async function _runMigrations() {
  try {
    const UserStats = require('./models/UserStats');
    const reset = await UserStats.updateMany(
      { 'skills.vocabulary': 3500, 'skills.listening': 3000,
        'skills.speaking': 2500,   'skills.writing': 2500 },
      { $set: { 'skills.vocabulary': 0, 'skills.listening': 0,
                'skills.speaking': 0,   'skills.writing': 0 } },
    );
    if (reset.modifiedCount > 0) {
      console.log(`[Migration v1] ${reset.modifiedCount} kullanıcının skill değerleri sıfırlandı.`);
    }
  } catch (err) {
    console.error('[Migration] Hata:', err.message);
  }
}

// ── Güvenlik middleware'leri ──────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '50kb' }));
app.use(mongoSanitize());

// ── Rate limiting ─────────────────────────────────────────────────
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { message: 'Çok fazla giriş denemesi. 15 dakika sonra tekrar deneyin.' },
  standardHeaders: true,
  legacyHeaders: false,
});
const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 100,
  message: { message: 'Çok fazla istek. Bir süre bekleyin.' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', apiLimiter);
app.use('/api/auth/login',    loginLimiter);
app.use('/api/auth/register', loginLimiter);

// ── Route'lar ─────────────────────────────────────────────────────
app.use('/api/auth',  require('./routes/auth'));
app.use('/api/vocab', require('./routes/vocab'));
app.use('/api/stats', require('./routes/stats'));
app.use('/api/ai',    require('./routes/ai'));

app.get('/health', (_, res) => res.json({ status: 'ok' }));

// 404
app.use((req, res) => {
  res.status(404).json({ message: 'Endpoint bulunamadı' });
});

// Global hata handler
app.use((err, req, res, _next) => {
  console.error('Beklenmeyen hata:', err);
  res.status(500).json({ message: 'Sunucu hatası' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Sunucu çalışıyor: http://localhost:${PORT}`));
