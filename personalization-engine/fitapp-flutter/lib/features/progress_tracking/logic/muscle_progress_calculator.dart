import '../../workout_library/domain/exercise.dart';
import '../data/progress_repository.dart';

class MuscleProgressCalculator {
  static int calculateMuscleVolume(
      String muscleName,
      List<Exercise> exercises,
      ) {

    return ProgressRepository.getLastSessionVolume();
  }
}