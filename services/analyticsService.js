const UserProgress = require('../models/UserProgress');

const analyticsService = {
    // 1. تجهيز بيانات الرسوم البيانية (Progress Charts)
    // ده بياخد بيانات المود أو الوزن ويجهزها في شكل (Array) سهل للفلاتر يرسمه
    getUserProgressStats: async (userId) => {
        const progress = await UserProgress.findOne({ userId });
        if (!progress) return { weights: [], moodTrends: [] };

        // تحويل سجل المود لبيانات مبسطة للـ Chart
        const moodTrends = progress.moodLogs.map(log => ({
            date: log.date.toISOString().split('T')[0], // التاريخ فقط
            score: log.moodScore
        }));

        return {
            currentXP: progress.totalXP,
            currentLevel: progress.level,
            moodTrends: moodTrends
        };
    },

    // 2. إنشاء التقرير الأسبوعي (Weekly Summary Report)
    // بيجمع إنجازات الأسبوع عشان يحفز المستخدم
    generateWeeklyReport: async (userId) => {
        const progress = await UserProgress.findOne({ userId });
        if (!progress) return "No data available";

        // منطق بسيط: تجميع عدد الأوسمة والنقاط اللي كسبها الأسبوع ده
        const weeklyXP = progress.totalXP; // في النسخة الكاملة هنطرح نقاط الأسبوع اللي فات
        const badgesCount = progress.badges.length;

        return {
            summary: `Great job! You are at Level ${progress.level} with ${badgesCount} badges earned so far.`,
            streak: progress.streak,
            totalXP: weeklyXP
        };
    }
};

module.exports = analyticsService;