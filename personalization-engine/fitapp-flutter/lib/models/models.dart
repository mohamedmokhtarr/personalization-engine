// ── UserProfile ───────────────────────────────────────────
class UserProfile {
  final String userId;
  final double weight;
  final double height;
  final int age;
  final String gender;
  final String activityLevel;
  final String injury;
  final double bmi;
  final int bmr;
  final int tdee;
  final String bmiCategory;

  const UserProfile({
    required this.userId,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.injury,
    required this.bmi,
    required this.bmr,
    required this.tdee,
    required this.bmiCategory,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final profile  = json['data']['profile']  as Map<String, dynamic>;
    final computed = json['data']['computed'] as Map<String, dynamic>;
    return UserProfile(
      userId:        profile['userId'],
      weight:        (profile['weight'] as num).toDouble(),
      height:        (profile['height'] as num).toDouble(),
      age:           profile['age'] as int,
      gender:        profile['gender'],
      activityLevel: profile['activityLevel'],
      injury:        profile['injury'] ?? 'none',
      bmi:           (computed['bmi']  as num).toDouble(),
      bmr:           computed['bmr']  as int,
      tdee:          computed['tdee'] as int,
      bmiCategory:   computed['bmiCategory'],
    );
  }
}

// ── Goal ──────────────────────────────────────────────────
class FitnessGoal {
  final String id;
  final String userId;
  final String goalType;
  final int baseCaloricTarget;
  final int adjustedCaloricTarget;
  final int caloricAdjustment;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int proteinPct;
  final int carbsPct;
  final int fatPct;
  final double weeklyWeightGoal;

  const FitnessGoal({
    required this.id,
    required this.userId,
    required this.goalType,
    required this.baseCaloricTarget,
    required this.adjustedCaloricTarget,
    required this.caloricAdjustment,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.weeklyWeightGoal,
  });

  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    final d = json['data'] is Map ? json['data']['goal'] ?? json['data'] : json;
    return FitnessGoal(
      id:                     d['_id'],
      userId:                 d['userId'],
      goalType:               d['goalType'],
      baseCaloricTarget:      d['baseCaloricTarget']     as int,
      adjustedCaloricTarget:  d['adjustedCaloricTarget'] as int,
      caloricAdjustment:      d['caloricAdjustment']     as int,
      proteinTarget:          d['proteinTarget']          as int,
      carbsTarget:            d['carbsTarget']            as int,
      fatTarget:              d['fatTarget']              as int,
      proteinPct:             d['proteinPct']             as int,
      carbsPct:               d['carbsPct']               as int,
      fatPct:                 d['fatPct']                 as int,
      weeklyWeightGoal:       (d['weeklyWeightGoal'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ── Workout ───────────────────────────────────────────────
class Workout {
  final String id;
  final String name;
  final String nameAr;
  final String muscle;
  final String muscleAr;
  final String intensity;
  final String equipment;
  final String icon;
  final List<String> injurySafe;
  final String sets;
  final String rest;
  final double met;

  const Workout({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.muscle,
    required this.muscleAr,
    required this.intensity,
    required this.equipment,
    required this.icon,
    required this.injurySafe,
    required this.sets,
    required this.rest,
    required this.met,
  });

  factory Workout.fromJson(Map<String, dynamic> json) => Workout(
        id:          json['_id'],
        name:        json['name'],
        nameAr:      json['nameAr'],
        muscle:      json['muscle'],
        muscleAr:    json['muscleAr'],
        intensity:   json['intensity'],
        equipment:   json['equipment'],
        icon:        json['icon'] ?? '💪',
        injurySafe:  List<String>.from(json['injurySafe'] ?? []),
        sets:        json['sets'] ?? '',
        rest:        json['rest'] ?? '',
        met:         (json['met'] as num?)?.toDouble() ?? 4.0,
      );
}

// ── MealSlot ──────────────────────────────────────────────
class MealSlot {
  final String time;
  final String mealNameAr;
  final String icon;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> foods;

  const MealSlot({
    required this.time,
    required this.mealNameAr,
    required this.icon,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.foods,
  });

  factory MealSlot.fromJson(Map<String, dynamic> json) => MealSlot(
        time:        json['time'] ?? '',
        mealNameAr:  json['mealNameAr'] ?? '',
        icon:        json['icon'] ?? '🍽️',
        calories:    json['calories'] as int,
        protein:     json['protein']  as int,
        carbs:       json['carbs']    as int,
        fat:         json['fat']      as int,
        foods:       List<String>.from(json['foods'] ?? []),
      );
}

// ── DailyPlan ─────────────────────────────────────────────
class DailyPlan {
  final String userId;
  final String date;
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final List<MealSlot> meals;
  final List<Workout> workouts;
  final String workoutTime;
  final int estimatedCalBurn;
  final int totalMealCalories;

  const DailyPlan({
    required this.userId,
    required this.date,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.meals,
    required this.workouts,
    required this.workoutTime,
    required this.estimatedCalBurn,
    required this.totalMealCalories,
  });

  int get netCalories => totalMealCalories - estimatedCalBurn;

  factory DailyPlan.fromJson(Map<String, dynamic> json) {
    final d = json['data']['plan'] as Map<String, dynamic>;
    final workout = d['workout'] as Map<String, dynamic>?;

    final workoutList = (workout?['workouts'] as List?)
            ?.map((w) => Workout.fromJson(w as Map<String, dynamic>))
            .toList() ??
        [];

    return DailyPlan(
      userId:           d['userId'],
      date:             d['date'],
      targetCalories:   d['targetCalories']   as int,
      targetProtein:    d['targetProtein']     as int,
      targetCarbs:      d['targetCarbs']       as int,
      targetFat:        d['targetFat']         as int,
      meals:            (d['meals'] as List).map((m) => MealSlot.fromJson(m as Map<String, dynamic>)).toList(),
      workouts:         workoutList,
      workoutTime:      workout?['time'] ?? '17:00',
      estimatedCalBurn: workout?['estimatedCalBurn'] as int? ?? 0,
      totalMealCalories:d['totalMealCalories'] as int,
    );
  }
}
