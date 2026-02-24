import 'package:flutter/material.dart';
import '../domain/workout_status.dart';


class WorkoutSessionController extends ChangeNotifier {
  WorkoutStatus status = WorkoutStatus.notStarted;
  int exerciseIndex = 0;


  void start() {
    status = WorkoutStatus.inProgress;
    notifyListeners();
  }


  void rest() {
    status = WorkoutStatus.resting;
    notifyListeners();
  }


  void nextExercise() {
    exerciseIndex++;
    status = WorkoutStatus.inProgress;
    notifyListeners();
  }


  void finish() {
    status = WorkoutStatus.completed;
    notifyListeners();
  }
}