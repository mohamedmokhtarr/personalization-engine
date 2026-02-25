const UserProgress = require('../models/UserProgress');

const moodService = {
    // 1. تسجيل موده وطاقته بعد التمرين (Post-workout feedback)
    logUserMood: async (userId, moodScore, energyLevel) => {
        const progress = await UserProgress.findOne({ userId });
        if (!progress) return null;

        const newLog = { 
            moodScore,    // درجة المود (1-5)
            energyLevel,  // مستوى الطاقة (1-5)
            date: new Date() 
        };
        
        // حفظ المود في السجل الخاص بالمستخدم في الداتابيز
        progress.moodLogs.push(newLog);
        await progress.save();

        return newLog;
    },

    // 2. تحليل المود لإرسال Signal لتعديل شدة التمرين (Mood-Based Adjustment)
    getMoodSignal: async (userId) => {
        const progress = await UserProgress.findOne({ userId });
        if (!progress || progress.moodLogs.length === 0) return 'NORMAL';

        // بنشوف آخر سجل للمود سجله المستخدم
        const lastLog = progress.moodLogs[progress.moodLogs.length - 1];

        // لو المود أو الطاقة منخفضين جداً (1 أو 2)، نطلب تقليل الشدة
        if (lastLog.moodScore <= 2 || lastLog.energyLevel <= 2) {
            return 'REDUCE_INTENSITY'; // دي الـ Signal اللي هيروح لمحمد مختار
        }

        return 'NORMAL';
    }
};

module.exports = moodService;