const express = require('express');
const router = express.Router();
const gamificationService = require('../services/gamificationService');

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

module.exports = router;