// lib/providers/workouts_provider.dart

import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';

class WorkoutsProvider with ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();
  List<WorkoutModel> _workouts = [];
  WorkoutModel? _selectedWorkout;

  List<WorkoutModel> get workouts => _workouts;
  WorkoutModel? get selectedWorkout => _selectedWorkout;

  /// טעינת כל האימונים מהשירות
  Future<void> loadWorkouts() async {
    try {
      _workouts = await _workoutService.getWorkoutPrograms();
    } catch (e) {
      debugPrint('שגיאה בטעינת אימונים: $e');
      _workouts = [];
    } finally {
      notifyListeners();
    }
  }

  /// רענון ידני – Pull To Refresh
  Future<void> reload() async {
    await loadWorkouts();
  }

  /// בחר אימון ספציפי
  void selectWorkout(WorkoutModel workout) {
    _selectedWorkout = workout;
    notifyListeners();
  }

  /// קבלת אימון לפי מזהה
  WorkoutModel? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (e) {
      debugPrint('אימון לא נמצא: $e');
      return null;
    }
  }

  /// הוספת אימון חדש
  void addWorkout(WorkoutModel workout) {
    _workouts.add(workout);
    notifyListeners();
  }

  /// עדכון אימון קיים
  void updateWorkout(WorkoutModel workout) {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
      notifyListeners();
    }
  }

  /// מחיקת אימון
  void deleteWorkout(String id) {
    _workouts.removeWhere((w) => w.id == id);
    notifyListeners();
  }

  /// שכפול אימון
  Future<WorkoutModel> duplicateWorkout(String id) async {
    final original = getWorkoutById(id);
    if (original == null) throw Exception('אימון לא נמצא');

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final duplicated = original.copyWith(
      id: '$timestamp-copy',
      title: '${original.title} (העתק)',
      date: DateTime.now(),
      metadata: {...?original.metadata, 'duplicated': true},
      exercises: original.exercises.map((ex) {
        final exerciseId = '$timestamp-${ex.id.hashCode}';
        return ex.copyWith(
          id: exerciseId,
          sets: ex.sets.map((s) {
            return s.copyWith(id: '$timestamp-${s.id.hashCode}');
          }).toList(),
        );
      }).toList(),
    );

    addWorkout(duplicated);
    return duplicated;
  }
}
