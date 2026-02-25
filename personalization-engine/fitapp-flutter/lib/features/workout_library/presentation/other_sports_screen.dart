import 'package:flutter/material.dart';
import 'package:personalization-engine/fitapp-flutter/features/workout_library/presentation/sport_exercises_screen.d.dart';
import '../data/exercise_repository.dart';
import '../../workout_session/presentation/workout_session_screen.dart';

class OtherSportsScreen extends StatelessWidget {
  const OtherSportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseRepository.getAllExercises()
        .where((e) => e.category != 'Gym')
        .toList();

    final sports = exercises
        .map((e) => e.category)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Other Sports')),
      body: ListView.builder(
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];

          return ListTile(
            title: Text(sport),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SportExercisesScreen(sportName: sport),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
