import 'package:flutter/foundation.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart';
import '../../../services/workout_service.dart';

class WorkoutsProvider with ChangeNotifier {
  final WorkoutService _workoutService;
  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;
  String? _error;

  WorkoutsProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  // Getters
  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load workouts
  Future<void> loadWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workouts = await _workoutService.getWorkouts();
      _error = null;
    } catch (e) {
      _error = 'שגיאה בטעינת האימונים';
      debugPrint('Error loading workouts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get exercise details for a workout
  Future<Map<String, Exercise>> getExerciseDetails(WorkoutModel workout) async {
    try {
      final exerciseIds = workout.exercises.map((e) => e.id).toList();
      return await _workoutService.getExerciseDetails(exerciseIds);
    } catch (e) {
      debugPrint('Error getting exercise details: $e');
      return {};
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _workoutService.deleteWorkout(workoutId);
      _workouts.removeWhere((w) => w.id == workoutId);
      notifyListeners();
    } catch (e) {
      _error = 'שגיאה במחיקת האימון';
      debugPrint('Error deleting workout: $e');
      notifyListeners();
    }
  }

  // Save workout (create or update)
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      if (workout.id.isEmpty) {
        // Create new workout
        final newWorkout = await _workoutService.createWorkout(workout);
        _workouts.add(newWorkout);
      } else {
        // Update existing workout
        final updatedWorkout = await _workoutService.updateWorkout(workout);
        final index = _workouts.indexWhere((w) => w.id == workout.id);
        if (index != -1) {
          _workouts[index] = updatedWorkout;
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'שגיאה בשמירת האימון';
      debugPrint('Error saving workout: $e');
      notifyListeners();
    }
  }
}
