const mongoose = require('mongoose');

const vocabSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    word: { type: String, required: true, trim: true },
    meaning: { type: String, required: true, trim: true },
    example: { type: String, default: '' },
    exampleTr: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Vocabulary', vocabSchema);
