const express = require('express');
const router = express.Router();
const gamificationService = require('../services/gamificationService');
const UserProgress = require("../models/UserProgress");

// ----------------------
// Add XP Route
// ----------------------
router.post('/add-xp', async (req, res) => {
    const { userId, activityType, workoutDuration, category } = req.body;

    const result = await gamificationService.calculateXP(
        userId,
        activityType,
        workoutDuration,
        category
    );

    res.json(result);
});

// ----------------------
// GET User Gamification Status
// ----------------------
router.get('/status/:userId', async (req, res) => {
    try {
        const user = await UserProgress.findOne({ userId: req.params.userId });

        if (user) {
            res.status(200).json(user);
        } else {
            res.status(404).json({ message: "User not found" });
        }
    } catch (error) {
        res.status(500).json({ message: "Error fetching status", error });
    }
});

module.exports = router;