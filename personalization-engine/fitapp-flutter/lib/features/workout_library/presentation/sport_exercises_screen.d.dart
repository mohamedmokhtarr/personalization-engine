import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../../workout_session/presentation/workout_session_screen.dart';

class SportExercisesScreen extends StatelessWidget {
  final String sportName;

  const SportExercisesScreen({
    super.key,
    required this.sportName,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseRepository.getAllExercises()
        .where((e) => e.category == sportName)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(sportName)),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];

          return Card(
            child: ListTile(
              title: Text(exercise.name),
              subtitle: Text(exercise.description),
              trailing: const Icon(Icons.play_arrow),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutSessionScreen(
                      exercises: exercises.map((e) => e.name).toList(),
                      startIndex: index,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
