const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: { type: String, required: true },
    level: {
      type: String,
      default: 'A2',
      enum: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'],
    },
    membershipJoinedAt: { type: Date, default: Date.now },
    dailyGoalMinutes: { type: Number, default: 20 },
    placementTestCompleted: { type: Boolean, default: false },
    placementTestScore: { type: Number, default: null },
    notificationsEnabled: { type: Boolean, default: true },
    dailyReminderEnabled: { type: Boolean, default: true },
    dailyReminderTimeMinutes: { type: Number, default: 1200 },
    soundEffectsEnabled: { type: Boolean, default: true },
    darkMode: { type: Boolean, default: false },
    // Refresh token, çıkışta null yapılarak oturum geçersiz kılınır.
    refreshToken: { type: String, default: null },
    // Parola sıfırlama OTP (6 haneli, 15 dakika geçerli)
    resetPasswordOtp:     { type: String, default: null },
    resetPasswordExpires: { type: Date,   default: null },
  },
  { timestamps: true }
);

// Şifreyi JSON cevabında asla gönderme.
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.password;
  delete obj.refreshToken;
  return obj;
};

module.exports = mongoose.model('User', userSchema);
