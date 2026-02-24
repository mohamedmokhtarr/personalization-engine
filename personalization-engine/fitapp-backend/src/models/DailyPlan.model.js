const mongoose = require("mongoose");

const mealSlotSchema = new mongoose.Schema({
  time:     { type: String },
  mealName: { type: String },
  mealNameAr: { type: String },
  calories: { type: Number },
  protein:  { type: Number },
  carbs:    { type: Number },
  fat:      { type: Number },
  foods:    [{ type: String }],
  icon:     { type: String },
}, { _id: false });

const workoutSlotSchema = new mongoose.Schema({
  time:      { type: String },
  workouts:  [{ type: mongoose.Schema.Types.ObjectId, ref: "Workout" }],
  totalMins: { type: Number },
  estimatedCalBurn: { type: Number },
}, { _id: false });

const dailyPlanSchema = new mongoose.Schema(
  {
    userId:   { type: String, required: true, index: true },
    date:     { type: String, required: true },          // "YYYY-MM-DD"
    goalId:   { type: mongoose.Schema.Types.ObjectId, ref: "Goal" },
    profileId:{ type: mongoose.Schema.Types.ObjectId, ref: "UserProfile" },

    // ── Targets for the day ───────────────────────────────
    targetCalories: { type: Number },
    targetProtein:  { type: Number },
    targetCarbs:    { type: Number },
    targetFat:      { type: Number },

    // ── Schedule ──────────────────────────────────────────
    meals:   [mealSlotSchema],
    workout: workoutSlotSchema,

    // ── Totals ────────────────────────────────────────────
    totalMealCalories: { type: Number },
  },
  { timestamps: true }
);

// Unique plan per user per day
dailyPlanSchema.index({ userId: 1, date: 1 }, { unique: true });

module.exports = mongoose.model("DailyPlan", dailyPlanSchema);
