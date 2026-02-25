import '../domain/workout_set.dart';

class VolumeCalculator {
  /// Volume = sum(weight * reps) for all sets
  static int calculateVolume(List<WorkoutSet> sets) {
    int total = 0;

    for (final set in sets) {
      total += (set.weight * set.reps).round();
    }

    return total;
  }
}
