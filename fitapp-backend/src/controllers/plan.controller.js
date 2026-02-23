const DailyPlan   = require("../models/DailyPlan.model");
const Goal        = require("../models/Goal.model");
const UserProfile = require("../models/UserProfile.model");
const Workout     = require("../models/Workout.model");

// ── Meal template generator ───────────────────────────────
function generateMeals(targetCal, targetProtein, targetCarbs, targetFat, goalType) {
  // Calorie distribution by meal
  const dist = { breakfast: 0.25, morningSnack: 0.10, lunch: 0.35, afternoonSnack: 0.10, dinner: 0.20 };

  const foodSuggestions = {
    lose: {
      breakfast:      ["شوفان بالحليب قليل الدسم", "بيضتان مسلوق", "تفاحة"],
      morningSnack:   ["زبادي يوناني 0% دسم"],
      lunch:          ["صدر فراخ مشوي 150g", "بروكلي مطبوخ", "سلطة خضراء"],
      afternoonSnack: ["تونة بالليمون", "خيارة"],
      dinner:         ["سمك مشوي 150g", "خضار مشوية", "شوربة عدس"],
    },
    gain: {
      breakfast:      ["شوفان بالحليب كامل الدسم", "3 بيضات مقلية", "موزتان", "توست أسمر"],
      morningSnack:   ["زبادي يوناني", "مكسرات مشكلة 30g", "عسل"],
      lunch:          ["صدر فراخ مشوي 200g", "أرز بني 200g", "أفوكادو", "سلطة"],
      afternoonSnack: ["تونة معلبة", "خبز أسمر 2 شريحة", "لبن"],
      dinner:         ["لحم مشوي 150g", "بطاطا حلوة 200g", "خضار مشوية", "زيت زيتون"],
    },
    recomp: {
      breakfast:      ["بيض 3 حبات", "خبز أسمر", "أفوكادو نص"],
      morningSnack:   ["زبادي يوناني", "توت"],
      lunch:          ["صدر فراخ 150g", "أرز بني 150g", "خضار مشوية"],
      afternoonSnack: ["مكسرات 20g", "تفاحة"],
      dinner:         ["سمك تونة أو سلمون", "بطاطا حلوة", "سلطة خضراء"],
    },
    maintain: {
      breakfast:      ["شوفان", "بيضتان", "موزة"],
      morningSnack:   ["فاكهة موسمية", "مكسرات خفيفة"],
      lunch:          ["صدر فراخ 130g", "أرز 130g", "خضار"],
      afternoonSnack: ["زبادي", "تفاحة"],
      dinner:         ["بروتين خفيف", "خضار", "شوربة"],
    },
  };

  const foods = foodSuggestions[goalType] || foodSuggestions.maintain;

  return [
    {
      time: "07:00", mealName: "Breakfast",     mealNameAr: "الفطار",      icon: "🌅",
      calories: Math.round(targetCal * dist.breakfast),
      protein:  Math.round(targetProtein * 0.25),
      carbs:    Math.round(targetCarbs   * 0.30),
      fat:      Math.round(targetFat     * 0.20),
      foods:    foods.breakfast,
    },
    {
      time: "10:30", mealName: "Morning Snack", mealNameAr: "سناك الصبح",  icon: "☕",
      calories: Math.round(targetCal * dist.morningSnack),
      protein:  Math.round(targetProtein * 0.10),
      carbs:    Math.round(targetCarbs   * 0.10),
      fat:      Math.round(targetFat     * 0.10),
      foods:    foods.morningSnack,
    },
    {
      time: "13:30", mealName: "Lunch",         mealNameAr: "الغدا",        icon: "🍽️",
      calories: Math.round(targetCal * dist.lunch),
      protein:  Math.round(targetProtein * 0.35),
      carbs:    Math.round(targetCarbs   * 0.35),
      fat:      Math.round(targetFat     * 0.30),
      foods:    foods.lunch,
    },
    {
      time: "16:30", mealName: "Afternoon Snack",mealNameAr:"سناك العصر",  icon: "🍎",
      calories: Math.round(targetCal * dist.afternoonSnack),
      protein:  Math.round(targetProtein * 0.10),
      carbs:    Math.round(targetCarbs   * 0.10),
      fat:      Math.round(targetFat     * 0.10),
      foods:    foods.afternoonSnack,
    },
    {
      time: "20:00", mealName: "Dinner",        mealNameAr: "العشا",        icon: "🌙",
      calories: Math.round(targetCal * dist.dinner),
      protein:  Math.round(targetProtein * 0.20),
      carbs:    Math.round(targetCarbs   * 0.15),
      fat:      Math.round(targetFat     * 0.30),
      foods:    foods.dinner,
    },
  ];
}

// ── POST /api/plan/generate ───────────────────────────────
exports.generatePlan = async (req, res, next) => {
  try {
    const { userId, date } = req.body;
    const planDate = date || new Date().toISOString().split("T")[0];

    // Fetch profile + active goal
    const [profile, goal] = await Promise.all([
      UserProfile.findOne({ userId }),
      Goal.findOne({ userId, isActive: true }),
    ]);

    if (!profile) return res.status(404).json({ success: false, message: "Profile not found" });
    if (!goal)    return res.status(404).json({ success: false, message: "No active goal found" });

    const targetCal     = goal.adjustedCaloricTarget || goal.baseCaloricTarget;
    const targetProtein = goal.proteinTarget;
    const targetCarbs   = goal.carbsTarget;
    const targetFat     = goal.fatTarget;

    // Select workouts for today — injury-aware + goal-intensity match
    const intensityMap  = { lose: "medium", gain: "high", recomp: "medium", maintain: "low" };
    const preferredIntensity = intensityMap[goal.goalType];
    const intensityLevels = { low: ["low"], medium: ["low","medium"], high: ["low","medium","high"] };

    const workouts = await Workout.find({
      injurySafe: profile.injury === "none" ? { $exists: true } : { $in: [profile.injury] },
      intensity:  { $in: intensityLevels[preferredIntensity] },
    }).limit(6);

    // Estimate calorie burn (avg MET * weight * time)
    const avgMET = workouts.reduce((s, w) => s + (w.met || 4), 0) / (workouts.length || 1);
    const estimatedCalBurn = Math.round(avgMET * profile.weight * (60 / 60)); // 60 min session

    // Build meals
    const meals = generateMeals(targetCal, targetProtein, targetCarbs, targetFat, goal.goalType);
    const totalMealCalories = meals.reduce((s, m) => s + m.calories, 0);

    const workoutTime = goal.goalType === "gain" ? "06:30" : "17:00";

    // Upsert plan (idempotent per user per day)
    const plan = await DailyPlan.findOneAndUpdate(
      { userId, date: planDate },
      {
        userId,
        date:      planDate,
        goalId:    goal._id,
        profileId: profile._id,
        targetCalories: targetCal,
        targetProtein,
        targetCarbs,
        targetFat,
        meals,
        workout: {
          time:             workoutTime,
          workouts:         workouts.map(w => w._id),
          totalMins:        60,
          estimatedCalBurn,
        },
        totalMealCalories,
      },
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );

    // Populate workouts for response
    await plan.populate("workout.workouts");

    res.status(200).json({
      success: true,
      data: {
        plan,
        summary: {
          date:            planDate,
          goalType:        goal.goalType,
          injury:          profile.injury,
          targetCalories:  targetCal,
          totalMealCalories,
          estimatedCalBurn,
          netCalories:     totalMealCalories - estimatedCalBurn,
          mealsCount:      meals.length,
          workoutsCount:   workouts.length,
        },
      },
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/plan/:userId/:date ───────────────────────────
exports.getPlan = async (req, res, next) => {
  try {
    const { userId, date } = req.params;
    const plan = await DailyPlan.findOne({ userId, date }).populate("workout.workouts");
    if (!plan) return res.status(404).json({ success: false, message: "No plan for this date" });
    res.json({ success: true, data: plan });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/plan/history/:userId ─────────────────────────
exports.getPlanHistory = async (req, res, next) => {
  try {
    const plans = await DailyPlan.find({ userId: req.params.userId })
      .sort({ date: -1 }).limit(30).select("-meals.foods");
    res.json({ success: true, count: plans.length, data: plans });
  } catch (err) {
    next(err);
  }
};
