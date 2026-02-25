const mongoose = require("mongoose");

const userProfileSchema = new mongoose.Schema(
  {
    // ── Identity ──────────────────────────────────────────
    userId: { type: String, required: true, unique: true, index: true },

    // ── Physical stats ────────────────────────────────────
    weight:    { type: Number, required: true, min: 20,  max: 300 },  // kg
    height:    { type: Number, required: true, min: 100, max: 250 },  // cm
    age:       { type: Number, required: true, min: 5,   max: 120 },
    gender:    { type: String, required: true, enum: ["male", "female"] },

    // ── Lifestyle ─────────────────────────────────────────
    activityLevel: {
      type: String,
      required: true,
      enum: ["sedentary", "light", "moderate", "active", "extreme"],
      default: "moderate",
    },

    // ── Injury ───────────────────────────────────────────
    injury: {
      type: String,
      enum: ["none", "knee", "shoulder", "back", "wrist", "ankle"],
      default: "none",
    },

    // ── Weight History (last 7 entries for graph) ─────────
    weightHistory: [
      {
        weight: { type: Number },
        date:   { type: Date, default: Date.now },
      },
    ],

    // ── Computed (stored for quick access) ────────────────
    bmi: { type: Number },
    bmr: { type: Number },
    tdee: { type: Number },
  },
  { timestamps: true }
);

// ── Pre-save: auto-compute BMI, BMR, TDEE ─────────────────
userProfileSchema.pre("save", function (next) {
  const ACTIVITY_MULTIPLIERS = {
    sedentary: 1.2,
    light:     1.375,
    moderate:  1.55,
    active:    1.725,
    extreme:   1.9,
  };

  // BMI = weight / (height in m)²
  this.bmi = parseFloat((this.weight / Math.pow(this.height / 100, 2)).toFixed(1));

  // BMR — Mifflin-St Jeor
  if (this.gender === "male") {
    this.bmr = Math.round(10 * this.weight + 6.25 * this.height - 5 * this.age + 5);
  } else {
    this.bmr = Math.round(10 * this.weight + 6.25 * this.height - 5 * this.age - 161);
  }

  // TDEE
  this.tdee = Math.round(this.bmr * ACTIVITY_MULTIPLIERS[this.activityLevel]);

  next();
});

// ── Instance method: BMI category ─────────────────────────
userProfileSchema.methods.getBMICategory = function () {
  if (this.bmi < 18.5) return { label: "Underweight", color: "#60a5fa" };
  if (this.bmi < 25)   return { label: "Normal",      color: "#4ade80" };
  if (this.bmi < 30)   return { label: "Overweight",  color: "#facc15" };
  return                      { label: "Obese",        color: "#f87171" };
};

module.exports = mongoose.model("UserProfile", userProfileSchema);