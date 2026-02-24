const UserProfile = require("../models/UserProfile.model");

// ── POST /api/profile ─────────────────────────────────────
// Create or update a user's health profile
exports.upsertProfile = async (req, res, next) => {
  try {
    const { userId, weight, height, age, gender, activityLevel, injury } = req.body;

    // Use findOneAndUpdate only to upsert the document shell,
    // then load it with .findOne() so pre-save hooks run via .save()
    let profile = await UserProfile.findOne({ userId });

    if (!profile) {
      profile = new UserProfile({ userId });
    }

    // Update fields
    profile.weight        = weight;
    profile.height        = height;
    profile.age           = age;
    profile.gender        = gender;
    profile.activityLevel = activityLevel;
    profile.injury        = injury || "none";

    // pre-save hook will auto-compute BMI, BMR, TDEE
    await profile.save();

    // ── Weight history: push new entry, keep last 7 only ──
    profile.weightHistory.push({ weight, date: new Date() });
    if (profile.weightHistory.length > 7) {
      profile.weightHistory.shift();
    }
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
        weightHistory: profile.weightHistory,
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