const mongoose = require('mongoose');

// بنوصف شكل البيانات اللي هنخزنها لكل مستخدم في جزء الـ Gamification
const userProgressSchema = new mongoose.Schema({
    // ده عشان نربط البيانات دي بمستخدم معين موجود عندنا في السيستم
    userId: { 
        type: String, 
        ref: 'User', 
        required: true 
    },
    
    // إجمالي النقاط اللي جمعها المستخدم (بتبدأ من صفر)
    totalXP: { 
        type: Number, 
        default: 0 
    }, 
    
    // مستوى المستخدم (بيبدأ من ليفل 1)
    level: { 
        type: Number, 
        default: 1 
    },

    // الـ Streak (عدد الأيام اللي ورا بعض اللي دخل فيها الأبلكيشن واتمرن)
    streak: { 
        type: Number, 
        default: 0 
    },

    // تاريخ آخر نشاط عمله (عشان نعرف لو غاب يوم نصفر الـ Streak)
    lastActivityDate: { 
        type: Date,
        default: Date.now
    },

    // قائمة بالأوسمة (Badges) اللي كسبها، وتاريخ كسبها
    // في ملف UserProgress.js داخل الـ Schema
    badges: [{ 
        badgeName: String, 
        description: String, // عشان يظهر تحت اسم الوسام
        icon: String,        // اسم الأيقونة (مثل 'fire', 'timer')
        earnedAt: { type: Date, default: Date.now } 
    }],

    xpHistory: [Number],
    weightHistory: [Number]
});

// بنحول الوصف ده لموديل جاهز للاستخدام
module.exports = mongoose.model('UserProgress', userProgressSchema);