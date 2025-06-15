// lib/providers/exercise_provider.dart

import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../data/exercise_data_store.dart';

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _error;

  List<Exercise> get exercises => _exercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // מייצר מפה מהירה: id -> Exercise
  Map<String, Exercise> get exerciseDetailsMap =>
      {for (final ex in _exercises) ex.id: ex};

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();
    try {
      _exercises = await ExerciseDataStore.loadExercises();
      _error = null;
    } catch (e) {
      _error = 'שגיאה בטעינת התרגילים: $e';
      _exercises = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Exercise> search({
    String? muscle,
    String? equipment,
    String? type,
    String? query,
  }) {
    return _exercises.where((ex) {
      final matchesMuscle = muscle == null ||
          (ex.mainMuscles?.contains(muscle) == true) ||
          (ex.secondaryMuscles?.contains(muscle) == true);
      final matchesEquipment = equipment == null || ex.equipment == equipment;
      final matchesType = type == null || ex.type == type;
      final matchesQuery = query == null ||
          ex.nameHe.contains(query) ||
          (ex.nameEn?.toLowerCase().contains(query.toLowerCase()) == true);
      return matchesMuscle && matchesEquipment && matchesType && matchesQuery;
    }).toList();
  }

  // Filter by muscle group
  bool muscleMatches(Exercise exercise, List<String> selectedMuscleGroups) {
    if (selectedMuscleGroups.isEmpty) return true;
    return (exercise.mainMuscles?.any((muscle) =>
                selectedMuscleGroups.contains(muscle.toLowerCase())) ==
            true) ||
        (exercise.secondaryMuscles?.any((muscle) =>
                selectedMuscleGroups.contains(muscle.toLowerCase())) ==
            true);
  }

  // Filter by equipment
  bool equipmentMatches(Exercise exercise, String selectedEquipment) {
    if (selectedEquipment.isEmpty) return true;
    return (exercise.equipment
            ?.toLowerCase()
            .contains(selectedEquipment.toLowerCase()) ==
        true);
  }
}
