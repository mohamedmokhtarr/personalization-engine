import '../domain/exercise.dart';

class ExerciseRepository {
  static List<Exercise> getAllExercises() {
    return const [

      // =====================
      // 🏋️ GYM – CHEST
      // =====================
      Exercise(
        name: "Bench Press",
        muscle: "Chest",
        category: "Gym",
        description: "Chest strength movement",
        videoAsset: "assets/videos/bench_press.mp4",
      ),

      Exercise(
        name: 'Incline Dumbbell Press',
        muscle: 'Chest',
        category: 'Gym',
        description: 'Upper chest focus',
        videoAsset: "assets/videos/incline_dumbbell_press.mp4",
      ),

      Exercise(
        name: 'Chest Fly',
        muscle: 'Chest',
        category: 'Gym',
        description: 'Isolation chest exercise',
        videoAsset: "assets/videos/chest_fly.mp4",
      ),

      // =====================
      // 🏋️ GYM – BACK
      // =====================
      Exercise(
        name: 'Lat Pulldown',
        muscle: 'Back',
        category: 'Gym',
        description: 'Vertical pulling exercise',
        videoAsset: "assets/videos/lat_pulldown.mp4",
      ),
      Exercise(
        name: 'Pull Up',
        muscle: 'Back',
        category: 'Gym',
        description: 'Bodyweight back exercise',
        videoAsset: "assets/videos/pull_up.mp4",
      ),
      Exercise(
        name: 'Barbell Row',
        muscle: 'Back',
        category: 'Gym',
        description: 'Horizontal pulling movement',
        videoAsset: "assets/videos/barbell_row.mp4",
      ),

      // =====================
      // 🏋️ GYM – LEGS
      // =====================
      Exercise(
        name: 'Squat',
        muscle: 'Legs',
        category: 'Gym',
        description: 'Lower body compound lift',
        videoAsset: "assets/videos/squat.mp4",
      ),
      Exercise(
        name: 'Leg Press',
        muscle: 'Legs',
        category: 'Gym',
        description: 'Machine-based leg exercise',
        videoAsset: "assets/videos/leg_press.mp4",
      ),
      Exercise(
        name: 'Romanian Deadlift',
        muscle: 'Legs',
        category: 'Gym',
        description: 'Hamstrings & glutes focus',
        videoAsset: "assets/videos/rdl.mp4",
      ),

      // =====================
      // 🏋️ GYM – SHOULDERS
      // =====================
      Exercise(
        name: 'Shoulder Press',
        muscle: 'Shoulders',
        category: 'Gym',
        description: 'Overhead press movement',
        videoAsset: "assets/videos/shoulder_press.mp4",
      ),
      Exercise(
        name: 'Lateral Raises',
        muscle: 'Shoulders',
        category: 'Gym',
        description: 'Side delts isolation',
        videoAsset: "assets/videos/lateral_raises.mp4",
      ),
      Exercise(
        name: 'Front Raises',
        muscle: 'Shoulders',
        category: 'Gym',
        description: 'Anterior delts focus',
        videoAsset: "assets/videos/front_raises.mp4",
      ),

      // =====================
      // 🏋️ GYM – ARMS
      // =====================
      Exercise(
        name: 'Biceps Curl',
        muscle: 'Arms',
        category: 'Gym',
        description: 'Biceps isolation',
        videoAsset: "assets/videos/biceps_curl.mp4",
      ),
      Exercise(
        name: 'Hammer Curl',
        muscle: 'Arms',
        category: 'Gym',
        description: 'Biceps & forearms',
        videoAsset: "assets/videos/hammer_curl.mp4",
      ),
      Exercise(
        name: 'Triceps Pushdown',
        muscle: 'Arms',
        category: 'Gym',
        description: 'Triceps isolation',
        videoAsset: "assets/videos/triceps_pushdown.mp4",
      ),

      // =====================
      // 🥋 KARATE
      // =====================
      Exercise(
        name: 'Kihon Practice',
        muscle: 'Full Body',
        category: 'Karate',
        description: 'Basic karate techniques',
        videoAsset: "assets/videos/kihon.mp4",
      ),
      Exercise(
        name: 'Kata Training',
        muscle: 'Full Body',
        category: 'Karate',
        description: 'Forms and patterns',
        videoAsset: "assets/videos/kata.mp4",
      ),
      Exercise(
        name: 'Kumite Drills',
        muscle: 'Full Body',
        category: 'Karate',
        description: 'Sparring techniques',
        videoAsset: "assets/videos/kumite.mp4",
      ),

      // =====================
      // 🥋 JUDO
      // =====================
      Exercise(
        name: 'Ukemi',
        muscle: 'Full Body',
        category: 'Judo',
        description: 'Breakfall techniques',
        videoAsset: "assets/videos/ukemi.mp4",
      ),
      Exercise(
        name: 'Nage Waza',
        muscle: 'Full Body',
        category: 'Judo',
        description: 'Throwing techniques',
        videoAsset: "assets/videos/nage_waza.mp4",
      ),
      Exercise(
        name: 'Ne Waza',
        muscle: 'Full Body',
        category: 'Judo',
        description: 'Ground techniques',
        videoAsset: "assets/videos/ne_waza.mp4",
      ),
    ];
  }
}
