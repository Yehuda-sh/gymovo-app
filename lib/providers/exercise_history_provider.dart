// lib/providers/exercise_history_provider.dart

import 'package:flutter/foundation.dart';
import '../models/exercise_history.dart';
import '../data/local_data_store.dart';

class ExerciseHistoryProvider with ChangeNotifier {
  Map<String, ExerciseHistory> _exerciseHistories = {};
  bool _isLoading = false;

  Map<String, ExerciseHistory> get exerciseHistories => _exerciseHistories;
  bool get isLoading => _isLoading;

  Future<void> loadExerciseHistories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final histories = await LocalDataStore.getExerciseHistories();
      _exerciseHistories = Map.fromEntries(
        histories.map((h) => MapEntry(h.exerciseId, h)),
      );
    } catch (e) {
      debugPrint('Error loading exercise histories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSet(String exerciseId, ExerciseSet set) async {
    try {
      final history = _exerciseHistories[exerciseId];
      if (history != null) {
        final updatedHistory = history.copyWith(
          sets: [...history.sets, set],
          lastWorkoutDate: DateTime.now(),
          totalSets: (history.totalSets ?? 0) + 1,
          totalVolume:
              (history.totalVolume ?? 0) + (set.weight * set.reps).round(),
        );
        updatedHistory.updatePersonalRecords(set);
        _exerciseHistories[exerciseId] = updatedHistory;
        await LocalDataStore.saveExerciseHistory(updatedHistory);
        notifyListeners();
      } else {
        final newHistory = ExerciseHistory(
          exerciseId: exerciseId,
          sets: [set],
          lastWorkoutDate: DateTime.now(),
          totalSets: 1,
          totalVolume: (set.weight * set.reps).round(),
        );
        newHistory.updatePersonalRecords(set);
        _exerciseHistories[exerciseId] = newHistory;
        await LocalDataStore.saveExerciseHistory(newHistory);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding set: $e');
    }
  }

  Future<void> updateSet(String exerciseId, ExerciseSet set) async {
    try {
      final history = _exerciseHistories[exerciseId];
      if (history != null) {
        final updatedSets = history.sets.map((s) {
          return s.id == set.id ? set : s;
        }).toList();

        final updatedHistory = history.copyWith(
          sets: updatedSets,
          lastWorkoutDate: DateTime.now(),
        );
        updatedHistory.updatePersonalRecords(set);

        _exerciseHistories[exerciseId] = updatedHistory;
        await LocalDataStore.saveExerciseHistory(updatedHistory);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating set: $e');
    }
  }

  Future<void> deleteSet(String exerciseId, String setId) async {
    try {
      final history = _exerciseHistories[exerciseId];
      if (history != null) {
        final updatedSets = history.sets.where((s) => s.id != setId).toList();
        final updatedHistory = history.copyWith(
          sets: updatedSets,
          lastWorkoutDate: DateTime.now(),
          totalSets: (history.totalSets ?? 0) - 1,
        );

        _exerciseHistories[exerciseId] = updatedHistory;
        await LocalDataStore.saveExerciseHistory(updatedHistory);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting set: $e');
    }
  }

  // --- חדש: החזרת סט שנמחק (Undo) ---
  Future<void> restoreSet(String exerciseId, ExerciseSet set) async {
    try {
      final history = _exerciseHistories[exerciseId];
      if (history != null) {
        final updatedHistory = history.copyWith(
          sets: [...history.sets, set]
            ..sort((a, b) => a.date.compareTo(b.date)),
          lastWorkoutDate: DateTime.now(),
          totalSets: (history.totalSets ?? 0) + 1,
        );
        updatedHistory.updatePersonalRecords(set);
        _exerciseHistories[exerciseId] = updatedHistory;
        await LocalDataStore.saveExerciseHistory(updatedHistory);
        notifyListeners();
      } else {
        // אם אין היסטוריה – צור חדשה עם הסט
        final newHistory = ExerciseHistory(
          exerciseId: exerciseId,
          sets: [set],
          lastWorkoutDate: DateTime.now(),
          totalSets: 1,
          totalVolume: (set.weight * set.reps).round(),
        );
        newHistory.updatePersonalRecords(set);
        _exerciseHistories[exerciseId] = newHistory;
        await LocalDataStore.saveExerciseHistory(newHistory);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring set: $e');
    }
  }

  ExerciseHistory? getExerciseHistory(String exerciseId) {
    return _exerciseHistories[exerciseId];
  }

  List<ExerciseSet> getRecentSets(String exerciseId, {int count = 5}) {
    final history = _exerciseHistories[exerciseId];
    if (history == null) return [];
    return history.getRecentSets(count);
  }

  Map<String, dynamic> getStatistics(String exerciseId) {
    final history = _exerciseHistories[exerciseId];
    if (history == null) return {};
    return history.getStatistics();
  }

  PersonalRecord? getPersonalRecord(String exerciseId, PRType type) {
    final history = _exerciseHistories[exerciseId];
    if (history == null) return null;
    return history.getPersonalRecord(type);
  }

  List<ExerciseSet> getSetsByType(String exerciseId, SetType type) {
    final history = _exerciseHistories[exerciseId];
    if (history == null) return [];
    return history.sets.where((set) => set.setType == type).toList();
  }

  List<ExerciseSet> getSetsByWorkout(String exerciseId, String workoutId) {
    final history = _exerciseHistories[exerciseId];
    if (history == null) return [];
    return history.sets.where((set) => set.workoutId == workoutId).toList();
  }

  List<ExerciseSet> getIncompleteSets(String exerciseId) {
    final history = _exerciseHistories[exerciseId];
    if (history == null) return [];
    return history.sets.where((set) => !set.isCompleted).toList();
  }
}
