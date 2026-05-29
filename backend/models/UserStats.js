const mongoose = require('mongoose');

const userStatsSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
      index: true,
    },
    // Günlük çalışma dakikaları: [{date: 20240523, minutes: 35}]
    dailyMinutes: [
      {
        date: { type: Number, required: true },   // yyyymmdd formatında
        minutes: { type: Number, default: 0 },
        _id: false,
      },
    ],
    streak: {
      lastDay: { type: Number, default: null },   // yyyymmdd
      count: { type: Number, default: 0 },
    },
    skills: {
      vocabulary: { type: Number, default: 0 },   // basis points (0-10000)
      listening: { type: Number, default: 0 },
      speaking: { type: Number, default: 0 },
      writing: { type: Number, default: 0 },
    },
    levelProgress: {
      type: Map,
      of: Number,                                  // level -> basis points
      default: {},
    },
    badges: {
      type: Map,
      of: Boolean,
      default: {},
    },
    listeningTotalMinutes: { type: Number, default: 0 },
    weeklyGoalMinutes: { type: Number, default: 300 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('UserStats', userStatsSchema);
