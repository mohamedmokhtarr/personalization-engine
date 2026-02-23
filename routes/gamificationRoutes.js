const express = require('express');
const router = express.Router();
const gamificationService = require('../services/gamificationService');
const analyticsService = require('../services/analyticsService');
const moodService = require('../services/moodService');

// 1. رابط إضافة نقاط للمستخدم (XP)
router.post('/add-xp', async (req, res) => {
    const { userId, activityType } = req.body;
    const result = await gamificationService.calculateXP(userId, activityType);
    res.json(result);
});

// 2. رابط الحصول على بيانات الـ Charts والمود
router.get('/stats/:userId', async (req, res) => {
    const stats = await analyticsService.getUserProgressStats(req.params.userId);
    res.json(stats);
});

// 3. رابط تسجيل المود والحصول على الـ Signal
router.post('/log-mood', async (req, res) => {
    const { userId, moodScore, energyLevel } = req.body;
    await moodService.logUserMood(userId, moodScore, energyLevel);
    const signal = await moodService.getMoodSignal(userId);
    res.json({ message: "Mood logged", recommendation: signal });
});

module.exports = router;