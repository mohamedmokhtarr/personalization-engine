const mongoose = require("mongoose");

const UserProgressSchema = new mongoose.Schema({
  userId: String,

  level: { type: Number, default: 1 },
  totalXP: { type: Number, default: 0 },

  xpHistory: [
    {
      date: { type: Date, required: true },
      xp: { type: Number, required: true }
    }
  ],

  weightHistory: [
    {
      date: { type: Date, required: true },
      weight: { type: Number, required: true }
    }
  ],

  streak: { type: Number, default: 0 },

  badges: [
    {
      id: Number,
      title: String,
      unlocked: Boolean
    }
  ],

  lastActivityDate: Date,
  workoutCategories: [String],
});

module.exports = mongoose.model("UserProgress", UserProgressSchema);