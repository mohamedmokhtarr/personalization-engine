const mongoose = require("mongoose");

const workoutSchema = new mongoose.Schema(
  {
    name:       { type: String, required: true },
    nameAr:     { type: String, required: true },
    muscle:     { type: String, required: true },
    muscleAr:   { type: String, required: true },
    intensity:  { type: String, enum: ["low", "medium", "high"], required: true },
    equipment:  { type: String, enum: ["gym", "home", "pool", "any"], default: "gym" },
    icon:       { type: String, default: "💪" },

    // Which injuries this exercise is SAFE for
    injurySafe: {
      type: [String],
      enum: ["none", "knee", "shoulder", "back", "wrist", "ankle"],
      default: ["none"],
    },

    sets:       { type: String },   // e.g. "4×8" or "30 min"
    repsRange:  { type: String },   // e.g. "6-8"
    rest:       { type: String },   // e.g. "3 min"
    met:        { type: Number },   // metabolic equivalent (for calorie burn)
    notes:      { type: String },
  },
  { timestamps: true }
);

workoutSchema.index({ intensity: 1, injurySafe: 1 });

module.exports = mongoose.model("Workout", workoutSchema);
