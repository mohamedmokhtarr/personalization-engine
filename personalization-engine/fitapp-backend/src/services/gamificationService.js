// استدعاء الموديل
const UserProgress = require('../models/UserProgress');

const gamificationService = {
    // 1. زيادة النقاط وتحديث التاريخ للجراف
    calculateXP: async (userId, activityType, workoutDuration = 0, category = null) => {
        let xpToAdd = 0;
        
        switch (activityType) {
            case 'WORKOUT_COMPLETED': xpToAdd = 50; break;
            case 'MEAL_LOGGED': xpToAdd = 10; break;
            case 'WATER_GOAL_MET': xpToAdd = 5; break;
            default: xpToAdd = 0;
        }

        // تحديث الـ XP، التاريخ، وأطول تمرينة، وتنوع الفئات
        let updateData = { 
            $inc: { totalXP: xpToAdd },
            $push: { xpHistory: xpToAdd }
        };

        // لو فيه بيانات إضافية جاية مع التمرينة (زي المدة أو النوع) بنحدثها
        if (workoutDuration > 0) {
            updateData['$max'] = { longestWorkoutMinutes: workoutDuration };
        }
        if (category) {
            updateData['$addToSet'] = { workoutCategories: category }; // addToSet بتمنع التكرار
        }

        let progress = await UserProgress.findOneAndUpdate(
            { userId },
            updateData,
            { new: true, upsert: true }
        );

        // الحفاظ على آخر 7 أيام فقط للجراف
        if (progress.xpHistory.length > 7) {
            progress.xpHistory.shift();
            await progress.save();
        }

        // 2. تحديث الـ Streak
        await gamificationService.updateStreak(userId);

        // 3. التحقق من الأوسمة (Badges)
        await gamificationService.checkBadges(userId);

        return await UserProgress.findOne({ userId });
    },

    // 2. حساب الـ Level
    checkLevelUp: (totalXP) => {
        return Math.floor(totalXP / 500) + 1;
    },

    // 3. تحديث الـ Streak
    updateStreak: async (userId) => {
        const progress = await UserProgress.findOne({ userId });
        if (!progress) return 0;

        const today = new Date().setHours(0,0,0,0);
        const lastActivity = progress.lastActivityDate ? new Date(progress.lastActivityDate).setHours(0,0,0,0) : null;

        if (lastActivity) {
            const diffInDays = (today - lastActivity) / (1000 * 60 * 60 * 24);
            if (diffInDays === 1) {
                progress.streak += 1;
            } else if (diffInDays > 1) {
                progress.streak = 1;
            }
        } else {
            progress.streak = 1;
        }

        progress.lastActivityDate = new Date();
        await progress.save();
        return progress.streak;
    },

    // 4. اللوجيك الخاص بالأوسمة (Badges)
    checkBadges: async (userId) => {
        const progress = await UserProgress.findOne({ userId });
        if (!progress) return [];
        const newBadges = [];

        // وسام الالتزام (7 أيام)
        if (progress.streak >= 7 && !progress.badges.some(b => b.badgeName === '7-Day Warrior')) {
            newBadges.push({ 
                badgeName: '7-Day Warrior', 
                description: 'Completed 7 days in a row!',
                icon: 'fire_icon' 
            });
        }

        // وسام تنوع التمارين (3 أنواع مختلفة)
        if (progress.workoutCategories && progress.workoutCategories.length >= 3 && !progress.badges.some(b => b.badgeName === 'Diversity King')) {
            newBadges.push({ 
                badgeName: 'Diversity King', 
                description: 'Tried 3 different workout types!',
                icon: 'category_icon'
            });
        }

        // وسام Stamina Master (تمرين > 30 دقيقة)
        if (progress.longestWorkoutMinutes >= 30 && !progress.badges.some(b => b.badgeName === 'Stamina Master')) {
            newBadges.push({ 
                badgeName: 'Stamina Master', 
                description: 'First workout over 30 minutes!',
                icon: 'timer_icon'
            });
        }

        if (newBadges.length > 0) {
            progress.badges.push(...newBadges);
            await progress.save();
        }
        return newBadges;
    }
};

module.exports = gamificationService;