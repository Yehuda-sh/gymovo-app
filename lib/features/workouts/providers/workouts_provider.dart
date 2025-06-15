import 'package:flutter/foundation.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart';
import '../../../services/workout_service.dart';

enum WorkoutLoadingState { idle, loading, success, error }

class WorkoutsProvider with ChangeNotifier {
  final WorkoutService _workoutService;

  List<WorkoutModel> _workouts = [];
  WorkoutLoadingState _loadingState = WorkoutLoadingState.idle;
  String? _error;

  // Cache for exercise details to avoid repeated API calls
  final Map<String, Exercise> _exerciseDetailsCache = {};

  WorkoutsProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  // Getters
  List<WorkoutModel> get workouts => List.unmodifiable(_workouts);
  WorkoutLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == WorkoutLoadingState.loading;
  bool get hasError => _loadingState == WorkoutLoadingState.error;
  String? get error => _error;
  bool get isEmpty =>
      _workouts.isEmpty && _loadingState != WorkoutLoadingState.loading;

  // Clear error state
  void clearError() {
    if (_error != null) {
      _error = null;
      _loadingState = WorkoutLoadingState.idle;
      notifyListeners();
    }
  }

  // Load workouts with better error handling
  Future<void> loadWorkouts({bool forceRefresh = false}) async {
    if (_loadingState == WorkoutLoadingState.loading) return;

    // Don't reload if already have data unless forced
    if (!forceRefresh && _workouts.isNotEmpty) return;

    _setLoadingState(WorkoutLoadingState.loading);

    try {
      final workouts = await _workoutService.getWorkouts();
      _workouts = workouts;
      _setLoadingState(WorkoutLoadingState.success);
    } catch (e) {
      _handleError('שגיאה בטעינת האימונים', e);
    }
  }

  // Get exercise details with caching
  Future<Map<String, Exercise>> getExerciseDetails(WorkoutModel workout) async {
    try {
      final exerciseIds = workout.exercises.map((e) => e.id).toList();
      final Map<String, Exercise> result = {};
      final List<String> idsToFetch = [];

      // Check cache first
      for (final id in exerciseIds) {
        if (_exerciseDetailsCache.containsKey(id)) {
          result[id] = _exerciseDetailsCache[id]!;
        } else {
          idsToFetch.add(id);
        }
      }

      // Fetch missing exercises
      if (idsToFetch.isNotEmpty) {
        final fetchedExercises =
            await _workoutService.getExerciseDetails(idsToFetch);

        // Update cache
        _exerciseDetailsCache.addAll(fetchedExercises);
        result.addAll(fetchedExercises);
      }

      return result;
    } catch (e) {
      debugPrint('Error getting exercise details: $e');
      return {};
    }
  }

  // Delete workout with optimistic updates
  Future<bool> deleteWorkout(String workoutId) async {
    final workoutIndex = _workouts.indexWhere((w) => w.id == workoutId);
    if (workoutIndex == -1) return false;

    // Store for rollback
    final deletedWorkout = _workouts[workoutIndex];

    // Optimistic update
    _workouts.removeAt(workoutIndex);
    notifyListeners();

    try {
      await _workoutService.deleteWorkout(workoutId);
      return true;
    } catch (e) {
      // Rollback on error
      _workouts.insert(workoutIndex, deletedWorkout);
      _handleError('שגיאה במחיקת האימון', e);
      return false;
    }
  }

  // Save workout with better handling
  Future<WorkoutModel?> saveWorkout(WorkoutModel workout) async {
    try {
      WorkoutModel savedWorkout;

      if (workout.id.isEmpty) {
        // Create new workout
        savedWorkout = await _workoutService.createWorkout(workout);
        _workouts.add(savedWorkout);
      } else {
        // Update existing workout
        savedWorkout = await _workoutService.updateWorkout(workout);
        final index = _workouts.indexWhere((w) => w.id == workout.id);
        if (index != -1) {
          _workouts[index] = savedWorkout;
        } else {
          // Workout not found locally, add it
          _workouts.add(savedWorkout);
        }
      }

      notifyListeners();
      return savedWorkout;
    } catch (e) {
      _handleError('שגיאה בשמירת האימון', e);
      return null;
    }
  }

  // Duplicate workout
  Future<WorkoutModel?> duplicateWorkout(WorkoutModel workout) async {
    try {
      final duplicatedWorkout = workout.copyWith(
        id: '', // Will get new ID from service
        title: '${workout.title} - עותק',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await saveWorkout(duplicatedWorkout);
    } catch (e) {
      _handleError('שגיאה בשכפול האימון', e);
      return null;
    }
  }

  // Reorder workouts
  void reorderWorkouts(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final WorkoutModel workout = _workouts.removeAt(oldIndex);
    _workouts.insert(newIndex, workout);
    notifyListeners();

    // Optionally save order to backend (commented out since method doesn't exist)
    // _saveWorkoutOrder();
  }

  // Search workouts
  List<WorkoutModel> searchWorkouts(String query) {
    if (query.isEmpty) return workouts;

    final lowerQuery = query.toLowerCase();
    return _workouts.where((workout) {
      return workout.title.toLowerCase().contains(lowerQuery) ||
          workout.description?.toLowerCase().contains(lowerQuery) == true ||
          workout.exercises.any(
              (exercise) => exercise.name.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Filter workouts by estimated duration
  List<WorkoutModel> getWorkoutsByDuration(int minMinutes, int maxMinutes) {
    return _workouts.where((workout) {
      // Calculate estimated duration based on sets and rest time
      final totalSets = workout.exercises
          .fold<int>(0, (sum, exercise) => sum + exercise.sets.length);

      // Rough estimation: 1.5 minutes per set
      final estimatedMinutes = totalSets * 1.5;

      return estimatedMinutes >= minMinutes && estimatedMinutes <= maxMinutes;
    }).toList();
  }

  // Get workout by ID
  WorkoutModel? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear cache
  void clearExerciseCache() {
    _exerciseDetailsCache.clear();
  }

  // Refresh all workouts
  Future<void> refreshWorkouts() async {
    await loadWorkouts(forceRefresh: true);
  }

  // Private helper methods
  void _setLoadingState(WorkoutLoadingState state) {
    _loadingState = state;
    if (state != WorkoutLoadingState.error) {
      _error = null;
    }
    notifyListeners();
  }

  void _handleError(String message, dynamic error) {
    _error = message;
    _loadingState = WorkoutLoadingState.error;
    debugPrint('WorkoutsProvider Error: $error');
    notifyListeners();
  }

  @override
  void dispose() {
    _exerciseDetailsCache.clear();
    super.dispose();
  }
}
