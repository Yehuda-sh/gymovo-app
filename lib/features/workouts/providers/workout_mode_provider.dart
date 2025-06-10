import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart';

class WorkoutModeProvider with ChangeNotifier {
  final WorkoutModel workout;
  final Map<String, Exercise> exerciseDetailsMap;

  // סטים שהושלמו, זמני מנוחה, מצב מנוחה
  final Map<String, Set<int>> _completedSets = {};
  final Map<String, int> _customRestTimes = {};
  int? _activeRestKey;
  int _restSeconds = 0;

  // --- סטופר ומצב אימון ---
  DateTime? _startTime;
  DateTime? _pausedTime;
  int _totalPausedSeconds = 0;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _isPaused = false;
  bool _forceStopped = false;

  WorkoutModeProvider({
    required this.workout,
    required this.exerciseDetailsMap,
  }) {
    _startTime = DateTime.now();
    startWorkout();
  }

  // --- Getters ---
  bool get isWorkoutComplete {
    for (var ex in workout.exercises) {
      if ((_completedSets[ex.id]?.length ?? 0) < ex.sets.length) return false;
    }
    return true;
  }

  int? get activeRestKey => _activeRestKey;
  int get restSeconds => _restSeconds;
  Map<String, Set<int>> get completedSets => _completedSets;
  Map<String, int> get customRestTimes => _customRestTimes;
  bool get isPaused => _isPaused;
  Duration get elapsed => _elapsed;
  bool get isForceStopped => _forceStopped;

  // Timer and Progress
  String get formattedElapsed {
    final elapsed =
        DateTime.now().difference(_startTime!).inSeconds - _totalPausedSeconds;
    final minutes = (elapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int get progressPercent {
    final totalSets =
        workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
    final completedSets =
        _completedSets.values.fold<int>(0, (sum, sets) => sum + sets.length);
    return totalSets > 0 ? (completedSets * 100 ~/ totalSets) : 0;
  }

  double get totalWeight {
    return workout.exercises.fold<double>(0, (sum, ex) {
      return sum +
          ex.sets.fold<double>(0, (setSum, set) {
            return setSum + (set.weight ?? 0) * (set.reps ?? 0);
          });
    });
  }

  // ===== סטופר =====
  void startWorkout() {
    if (_startTime == null) {
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
      _isPaused = false;
      _forceStopped = false;
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    }
  }

  void pauseWorkout() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeWorkout() {
    if (_isPaused) {
      _isPaused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
      notifyListeners();
    }
  }

  void stopWorkout() {
    _timer?.cancel();
    _forceStopped = true;
    notifyListeners();
  }

  void _onTick(Timer timer) {
    if (!_isPaused && !_forceStopped) {
      _elapsed = DateTime.now().difference(_startTime!);
      notifyListeners();
    }
  }

  // Methods
  void toggleSetComplete(String exId, int setIdx, int restTime) {
    _completedSets.putIfAbsent(exId, () => <int>{});
    if (_completedSets[exId]!.contains(setIdx)) {
      _completedSets[exId]!.remove(setIdx);
    } else {
      _completedSets[exId]!.add(setIdx);
      _activeRestKey = exId.hashCode + setIdx;
      _restSeconds = _customRestTimes[exId] ?? restTime;
    }
    notifyListeners();
  }

  void updateRestTime(String exId, int newRestTime) {
    _customRestTimes[exId] = newRestTime;
    notifyListeners();
  }

  void updateRestSeconds(int seconds) {
    _restSeconds = seconds;
    if (_restSeconds <= 0) {
      _activeRestKey = null;
    }
    notifyListeners();
  }

  void updateSet(String exId, int setIdx, ExerciseSet updatedSet) {
    final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
    if (setIdx < exercise.sets.length) {
      final currentSet = exercise.sets[setIdx];
      exercise.sets[setIdx] = currentSet.copyWith(
        weight: updatedSet.weight,
        reps: updatedSet.reps,
        restTime: updatedSet.restTime,
        isCompleted: updatedSet.isCompleted,
        notes: updatedSet.notes,
      );
      notifyListeners();
    }
  }

  void addSet(String exId, int afterSetIdx) {
    final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
    if (afterSetIdx < exercise.sets.length) {
      final templateSet = exercise.sets[afterSetIdx];
      exercise.sets.insert(
        afterSetIdx + 1,
        templateSet.copyWith(
          id: '${exId}_set_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
      notifyListeners();
    }
  }

  void deleteSet(String exId, int setIdx) {
    final exercise = workout.exercises.firstWhere((ex) => ex.id == exId);
    if (exercise.sets.length > 1 && setIdx < exercise.sets.length) {
      exercise.sets.removeAt(setIdx);
      notifyListeners();
    }
  }

  bool isSetCompleted(String exId, int setIdx) {
    return _completedSets[exId]?.contains(setIdx) ?? false;
  }

  bool isSetResting(String exId, int setIdx) {
    return _activeRestKey == exId.hashCode + setIdx && _restSeconds > 0;
  }

  int getRestTimeForExercise(String exId) {
    return _customRestTimes[exId] ??
        workout.exercises
            .firstWhere((ex) => ex.id == exId)
            .sets
            .first
            .restTime ??
        60;
  }

  void togglePause() {
    _isPaused = !_isPaused;
    if (_isPaused) {
      _pausedTime = DateTime.now();
    } else if (_pausedTime != null) {
      _totalPausedSeconds += DateTime.now().difference(_pausedTime!).inSeconds;
      _pausedTime = null;
    }
    notifyListeners();
  }
}
