import 'package:flutter/material.dart';

import '../data/exercise_repository.dart';
import '../../progress_tracking/data/progress_repository.dart';
import '../../workout_session/presentation/workout_session_screen.dart';

class MuscleExercisesScreen extends StatefulWidget {
  final String muscleName;

  const MuscleExercisesScreen({
    super.key,
    required this.muscleName,
  });

  @override
  State<MuscleExercisesScreen> createState() =>
      _MuscleExercisesScreenState();
}

class _MuscleExercisesScreenState extends State<MuscleExercisesScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final exercises = ExerciseRepository.getAllExercises()
        .where((e) =>
    e.category == 'Gym' &&
        e.muscle == widget.muscleName)
        .toList();

    final filtered = exercises
        .where((e) =>
        e.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // آخر سيشن Volume
    final lastVolume = ProgressRepository.getLastSessionVolume();

    return Scaffold(
      appBar: AppBar(title: Text(widget.muscleName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercise...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final exercise = filtered[index];

                return Card(
                  child: ListTile(
                    title: Text(exercise.name),
                    subtitle: lastVolume > 0
                        ? Text('Last session volume: $lastVolume kg')
                        : const Text('No progress yet'),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutSessionScreen(
                            exercises:
                            filtered.map((e) => e.name).toList(),
                            startIndex: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}