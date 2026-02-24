const mongoose = require("mongoose");

const ExerciseSchema = new mongoose.Schema({
    name: { type: String, required: true },
    duration: { type: Number, required: true },
    volume: { type: Number, required: true }
});

const ProgressSchema = new mongoose.Schema({
    userId: { type: String, required: false },
    totalSeconds: { type: Number, required: true },
    totalVolume: { type: Number, required: true },
    exercises: [ExerciseSchema],
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Progress", ProgressSchema);