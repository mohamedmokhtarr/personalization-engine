const Goal        = require("../models/Goal.model");
const UserProfile = require("../models/UserProfile.model");

// ── Goal config lookup ────────────────────────────────────
const GOAL_CONFIG = {
  lose:     { calAdj: -500, proteinMult: 2.0, weeklyKg: -0.5, label: "Weight Loss" },
  gain:     { calAdj: +400, proteinMult: 2.2, weeklyKg: +0.4, label: "Muscle Gain" },
  recomp:   { calAdj: 0,    proteinMult: 2.4, weeklyKg: 0,    label: "Body Recomposition" },
  maintain: { calAdj: 0,    proteinMult: 1.6, weeklyKg: 0,    label: "Maintenance" },
};

function calcMacros(targetCal, weight, proteinMult) {
  const proteinG = Math.round(weight * proteinMult);
  const proteinCal = proteinG * 4;
  const fatCal = targetCal * 0.25;
  const fatG = Math.round(fatCal / 9);
  const carbsCal = targetCal - proteinCal - fatCal;
  const carbsG = Math.round(Math.max(carbsCal, 0) / 4);

  return {
    protein: proteinG,
    carbs:   carbsG,
    fat:     fatG,
    proteinPct: Math.round((proteinCal / targetCal) * 100),
    carbsPct:   Math.round((carbsCal   / targetCal) * 100),
    fatPct:     Math.round((fatCal     / targetCal) * 100),
  };
}

// ── POST /api/goals ───────────────────────────────────────
// Create or update active goal for a user
exports.setGoal = async (req, res, next) => {
  try {
    const { userId, goalType, manualCaloricAdjustment = 0 } = req.body;

    // Need profile to get TDEE + weight
    const profile = await UserProfile.findOne({ userId });
    if (!profile) {
      return res.status(404).json({ success: false, message: "Profile not found. Create profile first." });
    }

    const config = GOAL_CONFIG[goalType];
    if (!config) {
      return res.status(400).json({ success: false, message: "Invalid goalType" });
    }

    const baseCaloricTarget     = profile.tdee + config.calAdj;
    const adjustedCaloricTarget = baseCaloricTarget + manualCaloricAdjustment;
    const macros = calcMacros(adjustedCaloricTarget, profile.weight, config.proteinMult);

    // Deactivate previous goals
    await Goal.updateMany({ userId, isActive: true }, { isActive: false });

    const goal = await Goal.create({
      userId,
      goalType,
      baseCaloricTarget,
      adjustedCaloricTarget,
      caloricAdjustment: manualCaloricAdjustment,
      proteinTarget: macros.protein,
      carbsTarget:   macros.carbs,
      fatTarget:     macros.fat,
      proteinPct:    macros.proteinPct,
      carbsPct:      macros.carbsPct,
      fatPct:        macros.fatPct,
      weeklyWeightGoal: config.weeklyKg,
      isActive: true,
    });

    res.status(201).json({
      success: true,
      data: {
        goal,
        summary: {
          label:          config.label,
          tdee:           profile.tdee,
          baseTarget:     baseCaloricTarget,
          adjustedTarget: adjustedCaloricTarget,
          macros,
          formula: {
            bmr:         profile.bmr,
            tdee:        profile.tdee,
            goalAdj:     config.calAdj,
            manualAdj:   manualCaloricAdjustment,
            finalTarget: adjustedCaloricTarget,
          },
        },
      },
    });
  } catch (err) {
    next(err);
  }
};

// ── PATCH /api/goals/:goalId/adjust ──────────────────────
// Smart adjustment — tweak calories ±150 without creating new goal
exports.adjustGoal = async (req, res, next) => {
  try {
    const { delta } = req.body;   // e.g. +150 or -150

    const goal = await Goal.findById(req.params.goalId);
    if (!goal) return res.status(404).json({ success: false, message: "Goal not found" });

    const profile = await UserProfile.findOne({ userId: goal.userId });

    goal.caloricAdjustment     = (goal.caloricAdjustment || 0) + delta;
    goal.adjustedCaloricTarget = goal.baseCaloricTarget + goal.caloricAdjustment;

    const config = GOAL_CONFIG[goal.goalType];
    const macros = calcMacros(goal.adjustedCaloricTarget, profile.weight, config.proteinMult);
    goal.proteinTarget = macros.protein;
    goal.carbsTarget   = macros.carbs;
    goal.fatTarget     = macros.fat;

    await goal.save();

    res.json({ success: true, data: { goal, macros } });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/goals/active/:userId ─────────────────────────
exports.getActiveGoal = async (req, res, next) => {
  try {
    const goal = await Goal.findOne({ userId: req.params.userId, isActive: true });
    if (!goal) return res.status(404).json({ success: false, message: "No active goal" });
    res.json({ success: true, data: goal });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/goals/history/:userId ────────────────────────
exports.getGoalHistory = async (req, res, next) => {
  try {
    const goals = await Goal.find({ userId: req.params.userId }).sort({ createdAt: -1 }).limit(10);
    res.json({ success: true, data: goals });
  } catch (err) {
    next(err);
  }
};
