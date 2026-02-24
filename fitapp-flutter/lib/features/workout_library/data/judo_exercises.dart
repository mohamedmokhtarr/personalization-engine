import '../domain/exercise.dart';

final List<Exercise> judoExercises = [
  Exercise(
    name: 'Ukemi (Break Falls)',
    muscle: 'Core',
    category: 'Judo',
    description: 'Breakfall techniques to safely absorb impact',
    videoAsset: "assets/videos/ukemi_breakfalls.mp4",
  ),
  Exercise(
    name: 'Grip Strength Drills',
    muscle: 'Forearms',
    category: 'Judo',
    description: 'Drills to improve grip strength and control',
    videoAsset: "assets/videos/grip_strength_drills.mp4",
  ),
  Exercise(
    name: 'Throw Entry Drills',
    muscle: 'Full Body',
    category: 'Judo',
    description: 'Practicing entries for throwing techniques',
    videoAsset: "assets/videos/throw_entry_drills.mp4",
  ),
  Exercise(
    name: 'Randori',
    muscle: 'Cardio',
    category: 'Judo',
    description: 'Free practice sparring to apply techniques',
    videoAsset: "assets/videos/randori.mp4",
  ),
];
