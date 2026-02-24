const mongoose = require("mongoose");

const goalSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, index: true },

    // ── Goal type ─────────────────────────────────────────
    goalType: {
      type: String,
      required: true,
      enum: ["lose", "gain", "recomp", "maintain"],
    },

    // ── Calorie targets ───────────────────────────────────
    baseCaloricTarget:     { type: Number, required: true },   // TDEE ± adjustment
    adjustedCaloricTarget: { type: Number },                   // after smart tweaks
    caloricAdjustment:     { type: Number, default: 0 },       // user manual delta

    // ── Macros (grams) ────────────────────────────────────
    proteinTarget: { type: Number, required: true },
    carbsTarget:   { type: Number, required: true },
    fatTarget:     { type: Number, required: true },

    // ── Macro split (%) ───────────────────────────────────
    proteinPct: { type: Number },
    carbsPct:   { type: Number },
    fatPct:     { type: Number },

    // ── Progress tracking ─────────────────────────────────
    weeklyWeightGoal: { type: Number },  // kg per week (+/-)
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

// ── Ensure only one active goal per user ──────────────────
goalSchema.pre("save", async function (next) {
  if (this.isNew && this.isActive) {
    await this.constructor.updateMany(
      { userId: this.userId, _id: { $ne: this._id } },
      { isActive: false }
    );
  }
  next();
});

module.exports = mongoose.model("Goal", goalSchema);
