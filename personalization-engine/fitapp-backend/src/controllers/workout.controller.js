const Workout = require("../models/Workout.model");

// ── Seed data ─────────────────────────────────────────────
const WORKOUT_SEED = [
  { name:"Barbell Bench Press",   nameAr:"دفع صدر بالبار",    muscle:"chest",    muscleAr:"صدر",    intensity:"high",   equipment:"gym",  icon:"🏋️", injurySafe:["none","knee","ankle"],                          sets:"4×6",  rest:"3 min",  met:6.0 },
  { name:"Dumbbell Press",        nameAr:"دفع صدر بالدمبل",   muscle:"chest",    muscleAr:"صدر",    intensity:"medium", equipment:"gym",  icon:"💪", injurySafe:["none","knee","ankle","back"],                   sets:"3×10", rest:"90s",    met:5.0 },
  { name:"Push Ups",              nameAr:"بوش آب",             muscle:"chest",    muscleAr:"صدر",    intensity:"medium", equipment:"home", icon:"🤸", injurySafe:["none","knee","ankle"],                          sets:"4×15", rest:"60s",    met:4.5 },
  { name:"Barbell Row",           nameAr:"سحب للبطن بالبار",  muscle:"back",     muscleAr:"ظهر",    intensity:"high",   equipment:"gym",  icon:"🔗", injurySafe:["none","knee","ankle"],                          sets:"4×8",  rest:"2 min",  met:6.0 },
  { name:"Lat Pulldown",          nameAr:"لات بولداون",       muscle:"back",     muscleAr:"ظهر",    intensity:"medium", equipment:"gym",  icon:"↕️", injurySafe:["none","knee","ankle","wrist"],                  sets:"4×10", rest:"90s",    met:5.0 },
  { name:"Lateral Raises",        nameAr:"كتف جانبي",          muscle:"shoulder", muscleAr:"كتف",    intensity:"low",    equipment:"gym",  icon:"↔️", injurySafe:["none","knee","ankle","back"],                   sets:"3×15", rest:"60s",    met:3.5 },
  { name:"Bicep Curl",            nameAr:"بايسبس كيرل",       muscle:"arms",     muscleAr:"ذراع",   intensity:"low",    equipment:"gym",  icon:"💪", injurySafe:["none","knee","ankle","back","shoulder"],        sets:"3×12", rest:"60s",    met:3.0 },
  { name:"Tricep Pushdown",       nameAr:"ترايسبس بوش داون",  muscle:"arms",     muscleAr:"ذراع",   intensity:"low",    equipment:"gym",  icon:"⬇️", injurySafe:["none","knee","ankle","back"],                   sets:"3×12", rest:"60s",    met:3.0 },
  { name:"Barbell Squat",         nameAr:"سكوات بالبار",      muscle:"legs",     muscleAr:"أرجل",   intensity:"high",   equipment:"gym",  icon:"🏋️", injurySafe:["none","shoulder","wrist"],                     sets:"4×6",  rest:"3 min",  met:7.0 },
  { name:"Leg Press",             nameAr:"ليج بريس",           muscle:"legs",     muscleAr:"أرجل",   intensity:"high",   equipment:"gym",  icon:"🦵", injurySafe:["none","shoulder","wrist","back"],               sets:"4×10", rest:"2 min",  met:6.0 },
  { name:"Leg Curl",              nameAr:"ليج كيرل",           muscle:"legs",     muscleAr:"أرجل",   intensity:"medium", equipment:"gym",  icon:"🔄", injurySafe:["none","shoulder","wrist","back"],               sets:"3×12", rest:"90s",    met:4.5 },
  { name:"Calf Raises",           nameAr:"كالف ريز",           muscle:"legs",     muscleAr:"أرجل",   intensity:"low",    equipment:"gym",  icon:"⬆️", injurySafe:["none","shoulder","wrist","back","knee"],        sets:"4×20", rest:"60s",    met:3.0 },
  { name:"Brisk Walk",            nameAr:"مشي سريع",           muscle:"cardio",   muscleAr:"كارديو", intensity:"low",    equipment:"any",  icon:"🚶", injurySafe:["none","shoulder","wrist","back","knee"],        sets:"30 min",rest:"—",     met:3.8 },
  { name:"HIIT Cardio",           nameAr:"هيت كارديو",         muscle:"cardio",   muscleAr:"كارديو", intensity:"high",   equipment:"any",  icon:"⚡", injurySafe:["none","shoulder","wrist"],                     sets:"20 min",rest:"—",     met:8.5 },
  { name:"Swimming",              nameAr:"سباحة",              muscle:"cardio",   muscleAr:"كارديو", intensity:"medium", equipment:"pool", icon:"🏊", injurySafe:["none","knee","ankle","back","shoulder","wrist"],sets:"45 min",rest:"—",     met:6.0 },
  { name:"Core Training",         nameAr:"تمارين كور",         muscle:"core",     muscleAr:"كور",    intensity:"medium", equipment:"home", icon:"🎯", injurySafe:["none","knee","ankle","shoulder","wrist"],       sets:"3×20", rest:"60s",    met:4.0 },
  { name:"General Stretching",    nameAr:"تمديد عام",          muscle:"flexibility",muscleAr:"مرونة",intensity:"low",   equipment:"home", icon:"🧘", injurySafe:["none","knee","ankle","shoulder","wrist","back"],sets:"15 min",rest:"—",     met:2.5 },
  { name:"Isometric Exercises",   nameAr:"إزومتريك عضلات",    muscle:"core",     muscleAr:"كور",    intensity:"low",    equipment:"home", icon:"🔒", injurySafe:["none","knee","ankle","shoulder","wrist","back"],sets:"5×30s", rest:"30s",   met:3.0 },
];

// ── POST /api/workouts/seed ───────────────────────────────
exports.seedWorkouts = async (req, res, next) => {
  try {
    await Workout.deleteMany({});
    const inserted = await Workout.insertMany(WORKOUT_SEED);
    res.json({ success: true, message: `Seeded ${inserted.length} workouts` });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/workouts ─────────────────────────────────────
// Query: ?injury=knee&intensity=medium&equipment=gym
exports.getWorkouts = async (req, res, next) => {
  try {
    const { injury = "none", intensity, equipment, muscle } = req.query;

    const filter = {};

    // Injury-aware filter: must include the user's injury in injurySafe
    if (injury && injury !== "none") {
      filter.injurySafe = { $in: [injury] };
    }

    if (intensity) {
      // Return exercises at or below the requested intensity
      const intensityMap = { low: ["low"], medium: ["low", "medium"], high: ["low", "medium", "high"] };
      filter.intensity = { $in: intensityMap[intensity] || ["low", "medium", "high"] };
    }

    if (equipment) filter.equipment = { $in: [equipment, "any"] };
    if (muscle)    filter.muscle    = muscle;

    const workouts = await Workout.find(filter).sort({ intensity: 1, name: 1 });

    res.json({
      success: true,
      count: workouts.length,
      data: workouts,
    });
  } catch (err) {
    next(err);
  }
};

// ── GET /api/workouts/:id ─────────────────────────────────
exports.getWorkoutById = async (req, res, next) => {
  try {
    const workout = await Workout.findById(req.params.id);
    if (!workout) return res.status(404).json({ success: false, message: "Workout not found" });
    res.json({ success: true, data: workout });
  } catch (err) {
    next(err);
  }
};
