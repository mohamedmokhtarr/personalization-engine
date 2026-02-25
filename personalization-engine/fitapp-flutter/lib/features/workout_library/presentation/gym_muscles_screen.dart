import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import 'muscle_exercises_screen.dart';

class GymMusclesScreen extends StatelessWidget {
  const GymMusclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseRepository.getAllExercises()
        .where((e) => e.category == 'Gym')
        .toList();

    final muscles = exercises
        .map((e) => e.muscle)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gym')),
      body: ListView.builder(
        itemCount: muscles.length,
        itemBuilder: (context, index) {
          final muscle = muscles[index];

          return ListTile(
            title: Text(muscle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MuscleExercisesScreen(muscleName: muscle),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
