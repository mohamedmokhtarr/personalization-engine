const UserProfile = require("../models/UserProfile.model");

// ── POST /api/profile ─────────────────────────────────────
// Create or update a user's health profile
exports.upsertProfile = async (req, res, next) => {
  try {
    const { userId, weight, height, age, gender, activityLevel, injury } = req.body;

    const profile = await UserProfile.findOneAndUpdate(
      { userId },
      { userId, weight, height, age, gender, activityLevel, injury: injury || "none" },
      { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true }
    );

    // Trigger pre-save hook manually after findOneAndUpdate
    // (Mongoose doesn't run pre-save on update — so we recalculate here)
    const MULTIPLIERS = { sedentary:1.2, light:1.375, moderate:1.55, active:1.725, extreme:1.9 };

    profile.bmi = parseFloat((weight / Math.pow(height / 100, 2)).toFixed(1));
    profile.bmr = gender === "male"
      ? Math.round(10 * weight + 6.25 * height - 5 * age + 5)
      : Math.round(10 * weight + 6.25 * height - 5 * age - 161);
    profile.tdee = Math.round(profile.bmr * MULTIPLIERS[activityLevel]);
    await profile.save();

    const bmiCategory = profile.getBMICategory();

    res.status(200).json({
      success: true,
      data: {
        profile,
        computed: {
          bmi:         profile.bmi,
          bmiCategory: bmiCategory.label,
          bmiColor:    bmiCategory.color,
          bmr:         profile.bmr,
          tdee:        profile.tdee,
        },
      },
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/profile/:userId ──────────────────────────────
exports.getProfile = async (req, res, next) => {
  try {
    const profile = await UserProfile.findOne({ userId: req.params.userId });

    if (!profile) {
      return res.status(404).json({ success: false, message: "Profile not found" });
    }

    const bmiCategory = profile.getBMICategory();

    res.json({
      success: true,
      data: {
        profile,
        computed: {
          bmi:         profile.bmi,
          bmiCategory: bmiCategory.label,
          bmiColor:    bmiCategory.color,
          bmr:         profile.bmr,
          tdee:        profile.tdee,
        },
      },
    });
  } catch (err) {
    next(err);
  }
};

// ── DELETE /api/profile/:userId ───────────────────────────
exports.deleteProfile = async (req, res, next) => {
  try {
    await UserProfile.findOneAndDelete({ userId: req.params.userId });
    res.json({ success: true, message: "Profile deleted" });
  } catch (err) {
    next(err);
  }
};
