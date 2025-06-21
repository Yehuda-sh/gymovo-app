// lib/features/workouts/providers/workout_mode_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart';

enum WorkoutStatus { notStarted, active, paused, completed, stopped }

class WorkoutModeProvider with ChangeNotifier {
  final WorkoutModel workout;
  final Map<String, Exercise> exerciseDetailsMap;

  // סטים שהושלמו, זמני מנוחה, מצב מנוחה
  final Map<String, Set<int>> _completedSets = {};
  final Map<String, int> _customRestTimes = {};
  String? _activeRestExerciseId;
  int? _activeRestSetIndex;
  int _restSeconds = 0;
  Timer? _restTimer;

  // --- סטופר ומצב אימון ---
  DateTime? _startTime;
  DateTime? _lastPauseTime;
  int _totalPausedSeconds = 0;
  Timer? _workoutTimer;
  WorkoutStatus _status = WorkoutStatus.notStarted;

  // נתונים סטטיסטיים
  int _totalVolume = 0; // משקל כולל × חזרות
  int _totalReps = 0;

  WorkoutModeProvider({
    required this.workout,
    required this.exerciseDetailsMap,
  });

  // --- Getters ---
  WorkoutStatus get status => _status;
  bool get isActive => _status == WorkoutStatus.active;
  bool get isPaused => _status == WorkoutStatus.paused;
  bool get isCompleted => _status == WorkoutStatus.completed;
  bool get isStopped => _status == WorkoutStatus.stopped;

  bool get isWorkoutComplete {
    if (workout.exercises.isEmpty) return false;

    for (var ex in workout.exercises) {
      final completedCount = _completedSets[ex.id]?.length ?? 0;
      if (completedCount < ex.sets.length) return false;
    }
    return true;
  }

  String? get activeRestExerciseId => _activeRestExerciseId;
  int? get activeRestSetIndex => _activeRestSetIndex;
  int get restSeconds => _restSeconds;
  bool get isResting => _activeRestExerciseId != null && _restSeconds > 0;

  Map<String, Set<int>> get completedSets => Map.unmodifiable(_completedSets);
  Map<String, int> get customRestTimes => Map.unmodifiable(_customRestTimes);

  int get totalVolume => _totalVolume;
  int get totalReps => _totalReps;

  // זמן אימון מעוצב
  String get formattedElapsed {
    if (_startTime == null) return '00:00';

    final now = DateTime.now();
    int elapsedSeconds = now.difference(_startTime!).inSeconds;

    // הפחת זמן השהיה
    elapsedSeconds -= _totalPausedSeconds;

    // אם במצב השהיה כרגע
    if (_status == WorkoutStatus.paused && _lastPauseTime != null) {
      elapsedSeconds -= now.difference(_lastPauseTime!).inSeconds;
    }

    elapsedSeconds = elapsedSeconds.clamp(0, 999999);

    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // אחוז התקדמות
  int get progressPercent {
    final totalSets =
        workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
    if (totalSets == 0) return 0;

    final completedCount =
        _completedSets.values.fold<int>(0, (sum, sets) => sum + sets.length);
    return (completedCount * 100 / totalSets).round().clamp(0, 100);
  }

  // משקל כולל מחושב
  double get totalWeight {
    return workout.exercises.fold<double>(0, (sum, ex) {
      final completedSetsForEx = _completedSets[ex.id] ?? <int>{};
      return sum +
          ex.sets.asMap().entries.fold<double>(0, (setSum, entry) {
            final setIndex = entry.key;
            final set = entry.value;

            // רק סטים שהושלמו
            if (completedSetsForEx.contains(setIndex)) {
              return setSum + (set.weight ?? 0) * (set.reps ?? 0);
            }
            return setSum;
          });
    });
  }

  // סטטיסטיקות מפורטות
  Map<String, dynamic> get workoutStats {
    final completedSetsCount =
        _completedSets.values.fold<int>(0, (sum, sets) => sum + sets.length);
    final totalSetsCount =
        workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);

    return {
      'duration': formattedElapsed,
      'completedSets': completedSetsCount,
      'totalSets': totalSetsCount,
      'progressPercent': progressPercent,
      'totalWeight': totalWeight,
      'exercisesCount': workout.exercises.length,
      'completedExercises': _getCompletedExercisesCount(),
    };
  }

  int _getCompletedExercisesCount() {
    return workout.exercises.where((ex) {
      final completedCount = _completedSets[ex.id]?.length ?? 0;
      return completedCount == ex.sets.length;
    }).length;
  }

  // ===== ניהול סטופר =====
  void startWorkout() {
    if (_status != WorkoutStatus.notStarted) return;

    _startTime = DateTime.now();
    _status = WorkoutStatus.active;
    _startWorkoutTimer();
    notifyListeners();
  }

  void pauseWorkout() {
    if (_status != WorkoutStatus.active) return;

    _lastPauseTime = DateTime.now();
    _status = WorkoutStatus.paused;
    _workoutTimer?.cancel();
    _pauseRestTimer();
    notifyListeners();
  }

  void resumeWorkout() {
    if (_status != WorkoutStatus.paused) return;

    if (_lastPauseTime != null) {
      _totalPausedSeconds +=
          DateTime.now().difference(_lastPauseTime!).inSeconds;
      _lastPauseTime = null;
    }

    _status = WorkoutStatus.active;
    _startWorkoutTimer();
    _resumeRestTimer();
    notifyListeners();
  }

  void stopWorkout() {
    _status = WorkoutStatus.stopped;
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    notifyListeners();
  }

  void completeWorkout() {
    _status = WorkoutStatus.completed;
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    _activeRestExerciseId = null;
    _activeRestSetIndex = null;
    _restSeconds = 0;
    notifyListeners();
  }

  void togglePause() {
    if (_status == WorkoutStatus.active) {
      pauseWorkout();
    } else if (_status == WorkoutStatus.paused) {
      resumeWorkout();
    }
  }

  void _startWorkoutTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == WorkoutStatus.active) {
        notifyListeners();
      }
    });
  }

  // ===== ניהול סטים =====
  void toggleSetComplete(String exId, int setIdx) {
    if (_status != WorkoutStatus.active && _status != WorkoutStatus.paused)
      return;

    _completedSets.putIfAbsent(exId, () => <int>{});

    if (_completedSets[exId]!.contains(setIdx)) {
      // ביטול השלמת סט
      _completedSets[exId]!.remove(setIdx);
      _updateStats();
    } else {
      // השלמת סט
      _completedSets[exId]!.add(setIdx);
      _updateStats();

      // התחלת מנוחה
      final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
      if (setIdx < exercise.sets.length) {
        final restTime = _customRestTimes[exId] ??
            exercise.sets[setIdx].restTime ??
            _getDefaultRestTime(exId);

        if (restTime > 0) {
          _startRestTimer(exId, setIdx, restTime);
        }
      }

      // בדיקה אם האימון הושלם
      if (isWorkoutComplete) {
        completeWorkout();
      }
    }

    notifyListeners();
  }

  void _updateStats() {
    _totalVolume = 0;
    _totalReps = 0;

    for (var exercise in workout.exercises) {
      final completedSetsForEx = _completedSets[exercise.id] ?? <int>{};

      for (int i = 0; i < exercise.sets.length; i++) {
        if (completedSetsForEx.contains(i)) {
          final set = exercise.sets[i];
          final weight = set.weight ?? 0;
          final reps = set.reps ?? 0;

          _totalVolume += (weight * reps).round();
          _totalReps += reps;
        }
      }
    }
  }

  int _getDefaultRestTime(String exId) {
    final exerciseDetails = exerciseDetailsMap[exId];
    if (exerciseDetails != null) {
      // זמן מנוחה לפי סוג התרגיל
      switch (exerciseDetails.type.name.toLowerCase()) {
        case 'strength':
        case 'powerlifting':
          return 180; // 3 דקות
        case 'cardio':
          return 30;
        case 'isolation':
          return 60;
        default:
          return 90;
      }
    }
    return 90; // ברירת מחדל
  }

  // ===== ניהול מנוחה =====
  void _startRestTimer(String exId, int setIdx, int restTime) {
    _stopRestTimer();

    _activeRestExerciseId = exId;
    _activeRestSetIndex = setIdx;
    _restSeconds = restTime;

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status == WorkoutStatus.active) {
        _restSeconds--;
        if (_restSeconds <= 0) {
          _stopRestTimer();
        }
        notifyListeners();
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _activeRestExerciseId = null;
    _activeRestSetIndex = null;
    _restSeconds = 0;
  }

  void _pauseRestTimer() {
    _restTimer?.cancel();
  }

  void _resumeRestTimer() {
    if (_activeRestExerciseId != null && _restSeconds > 0) {
      _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_status == WorkoutStatus.active) {
          _restSeconds--;
          if (_restSeconds <= 0) {
            _stopRestTimer();
          }
          notifyListeners();
        }
      });
    }
  }

  void skipRest() {
    _stopRestTimer();
    notifyListeners();
  }

  void addRestTime(int seconds) {
    _restSeconds += seconds;
    notifyListeners();
  }

  void updateCustomRestTime(String exId, int newRestTime) {
    _customRestTimes[exId] = newRestTime.clamp(10, 600); // 10 שניות עד 10 דקות
    notifyListeners();
  }

  // ===== ניהול סטים ותרגילים =====
  void updateSet(String exId, int setIdx, ExerciseSet updatedSet) {
    final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
    if (setIdx >= 0 && setIdx < exercise.sets.length) {
      exercise.sets[setIdx] = updatedSet;
      _updateStats();
      notifyListeners();
    }
  }

  void addSet(String exId, {int? afterSetIdx}) {
    final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
    final insertIndex =
        afterSetIdx != null ? afterSetIdx + 1 : exercise.sets.length;

    // יצירת סט חדש בהתבסס על הסט הקודם
    ExerciseSet templateSet;
    if (exercise.sets.isNotEmpty) {
      final sourceIndex = afterSetIdx ?? exercise.sets.length - 1;
      templateSet = exercise.sets[sourceIndex];
    } else {
      templateSet = ExerciseSet(
        id: '',
        reps: 10,
        weight: 0,
        restTime: 90,
      );
    }

    final newSet = templateSet.copyWith(
      id: '${exId}_set_${DateTime.now().millisecondsSinceEpoch}',
      isCompleted: false,
      notes: null,
    );

    exercise.sets.insert(insertIndex, newSet);
    notifyListeners();
  }

  void deleteSet(String exId, int setIdx) {
    final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
    if (exercise.sets.length > 1 &&
        setIdx >= 0 &&
        setIdx < exercise.sets.length) {
      exercise.sets.removeAt(setIdx);

      // עדכון סטים שהושלמו
      final completedSetsForEx = _completedSets[exId];
      if (completedSetsForEx != null) {
        // הסרת הסט שנמחק
        completedSetsForEx.remove(setIdx);

        // עדכון אינדקסים של סטים שהושלמו
        final updatedCompleted = <int>{};
        for (final completedIdx in completedSetsForEx) {
          if (completedIdx > setIdx) {
            updatedCompleted.add(completedIdx - 1);
          } else {
            updatedCompleted.add(completedIdx);
          }
        }
        _completedSets[exId] = updatedCompleted;
      }

      _updateStats();
      notifyListeners();
    }
  }

  // ===== פונקציות עזר =====
  bool isSetCompleted(String exId, int setIdx) {
    return _completedSets[exId]?.contains(setIdx) ?? false;
  }

  bool isSetResting(String exId, int setIdx) {
    return _activeRestExerciseId == exId &&
        _activeRestSetIndex == setIdx &&
        _restSeconds > 0;
  }

  int getRestTimeForExercise(String exId) {
    return _customRestTimes[exId] ?? _getDefaultRestTime(exId);
  }

  String getRestTimeFormatted() {
    if (_restSeconds <= 0) return '';

    final minutes = _restSeconds ~/ 60;
    final seconds = _restSeconds % 60;

    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  // נתוני סיכום לסיום האימון
  Map<String, dynamic> getWorkoutSummary() {
    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds - _totalPausedSeconds
        : 0;

    return {
      'workoutId': workout.id,
      'title': workout.title,
      'duration': duration,
      'completedSets':
          _completedSets.values.fold<int>(0, (sum, sets) => sum + sets.length),
      'totalSets':
          workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length),
      'totalWeight': totalWeight,
      'totalReps': _totalReps,
      'totalVolume': _totalVolume,
      'exercisesCount': workout.exercises.length,
      'completedExercises': _getCompletedExercisesCount(),
      'startTime': _startTime?.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'isCompleted': isWorkoutComplete,
    };
  }

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
