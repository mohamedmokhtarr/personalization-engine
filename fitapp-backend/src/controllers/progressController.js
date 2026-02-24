const Progress = require("../models/Progress");

exports.saveProgress = async (req, res) => {
    try {
        const { userId, totalSeconds, totalVolume, exercises } = req.body;

        const newProgress = new Progress({
            userId,
            totalSeconds,
            totalVolume,
            exercises
        });

        await newProgress.save();

        res.status(200).json({ message: "Progress saved successfully", data: newProgress });
    } catch (error) {
        console.error("Save Error:", error);
        res.status(500).json({ message: "Error saving progress" });
    }
};