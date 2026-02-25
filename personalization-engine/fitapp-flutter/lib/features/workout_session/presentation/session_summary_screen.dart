import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../progress_tracking/domain/workout_set.dart';
import '../../progress_tracking/logic/volume_calculator.dart';
import '../../progress_tracking/data/progress_repository.dart';
import '../../gamification/logic/gamification_provider.dart';

class SessionSummaryScreen extends StatelessWidget {
  final Map<String, List<WorkoutSet>> sessionSets;
  final int sessionSeconds;
  final Map<String, int> exerciseDurations;

  const SessionSummaryScreen({
    super.key,
    required this.sessionSets,
    required this.sessionSeconds,
    required this.exerciseDurations,
  });

  // --------------------------
  // CATEGORY DETECTION
  // --------------------------
  String getCategory(String exerciseName) {
    if (exerciseName.contains("Bench")) return "Chest";
    if (exerciseName.contains("Squat")) return "Legs";
    if (exerciseName.contains("Deadlift")) return "Back";
    if (exerciseName.contains("Press")) return "Shoulders";
    return "General";
  }

  // --------------------------
  // SAVE SESSION TO BACKEND
  // --------------------------
  Future<void> saveSessionToBackend({
    required int sessionSeconds,
    required int totalVolume,
    required Map<String, int> exerciseDurations,
    required Map<String, int> exerciseVolumes,
  }) async {
    final data = {
      "userId": "yasmine-01",
      "totalSeconds": sessionSeconds,
      "totalVolume": totalVolume,
      "exercises": exerciseVolumes.keys.map((name) {
        return {
          "name": name,
          "duration": exerciseDurations[name] ?? 0,
          "volume": exerciseVolumes[name] ?? 0,
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/progress/save"), // ← عدّلي هنا
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("Progress Backend Response: ${response.body}");
    } catch (e) {
      print("Error sending session: $e");
    }
  }

  // --------------------------
  // SEND GAMIFICATION XP
  // --------------------------
  Future<void> sendGamificationXP({
    required int longestDuration,
    required Map<String, int> exerciseDurations,
  }) async {
    // XP for general workout
    await http.post(
      Uri.parse("http://10.0.2.2:5000/api/gamification/add-xp"), // ← عدّلي هنا
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": "yasmine-01",
        "activityType": "WORKOUT_COMPLETED",
        "workoutDuration": longestDuration ~/ 60,
      }),
    );

    // XP per category
    for (var entry in exerciseDurations.entries) {
      await http.post(
        Uri.parse("http://10.0.2.2:5000/api/gamification/add-xp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": "yasmine-01",
          "activityType": "WORKOUT_COMPLETED",
          "workoutDuration": longestDuration ~/ 60,
          "category": getCategory(entry.key),
        }),
      );
    }
  }

  // Format Time
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> exerciseVolumes = {};

    sessionSets.forEach((exercise, sets) {
      exerciseVolumes[exercise] = VolumeCalculator.calculateVolume(sets);
    });

    final int currentSessionVolume =
    exerciseVolumes.values.fold(0, (a, b) => a + b);

    final int lastSessionVolume = ProgressRepository.getLastSessionVolume();
    final int diff = currentSessionVolume - lastSessionVolume;

    final int longestDuration = exerciseDurations.values.fold(
      0,
          (a, b) => a > b ? a : b,
    );

    ProgressRepository.saveSession(currentSessionVolume);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Time: ${_formatTime(sessionSeconds)}',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text(
              'Total Volume: $currentSessionVolume kg',
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              diff > 0
                  ? 'Progress: +$diff kg 🔥'
                  : diff < 0
                  ? 'Progress: $diff kg'
                  : 'Same as last session',
              style: TextStyle(
                fontSize: 16,
                color: diff > 0
                    ? Colors.green
                    : diff < 0
                    ? Colors.red
                    : Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: sessionSets.entries.map((entry) {
                  final name = entry.key;
                  final sets = entry.value;
                  final volume = exerciseVolumes[name] ?? 0;
                  final duration = exerciseDurations[name] ?? 0;

                  return Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text(
                        '${sets.length} sets • $volume kg • ${_formatTime(duration)}',
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------
            // FINISH WORKOUT BUTTON (API CALLS HERE)
            // -----------------------------------------
            ElevatedButton(
              onPressed: () async {
                await saveSessionToBackend(
                  sessionSeconds: sessionSeconds,
                  totalVolume: currentSessionVolume,
                  exerciseDurations: exerciseDurations,
                  exerciseVolumes: exerciseVolumes,
                );

                await sendGamificationXP(
                  longestDuration: longestDuration,
                  exerciseDurations: exerciseDurations,
                );

                // Refresh provider at your side
                Provider.of<GamificationProvider>(context, listen: false)
                    .fetchProgress();

                Navigator.pop(context);
              },
              child: const Text("Finish Workout"),
            ),
          ],
        ),
      ),
    );
  }
}