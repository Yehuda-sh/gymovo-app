//../lib/services/workout_plan_builder.dart

import '../models/exercise.dart';

class WorkoutPlan {
  final Map<String, List<Exercise>> days;
  final String difficulty;
  final String goal;
  final int totalExercises;

  WorkoutPlan({
    required this.days,
    required this.difficulty,
    required this.goal,
    required this.totalExercises,
  });

  int get totalDays => days.length;
  int get averageExercisesPerDay => totalExercises ~/ totalDays;
}

class WorkoutPlanBuilder {
  static const List<String> _dayNames = [
    'ראשון',
    'שני',
    'שלישי',
    'רביעי',
    'חמישי',
    'שישי',
    'שבת'
  ];
  static const int _defaultExercisesPerDay = 5;
  static const int _defaultDaysPerWeek = 3;

  static WorkoutPlan buildCustomPlan(
    Map<String, dynamic> answers,
    List<Exercise> allExercises,
  ) {
    final daysPerWeek = answers['frequency'] == null
        ? _defaultDaysPerWeek
        : _mapFrequencyToDays(answers['frequency']);

    final exercisesPerDay = _defaultExercisesPerDay;
    final difficulty = answers['experience_level'] ?? 'מתחיל';
    final goal = answers['goal'] ?? 'כללי';

    final preferredMuscles = List<String>.from(
      answers['main_muscles_focus'] ?? [],
    );
    final equipment = List<String>.from(
      answers['equipment_types'] ?? [],
    );
    final avoid = List<String>.from(
      answers['avoid_exercises'] ?? [],
    );
    final pain = List<String>.from(
      answers['pain_or_limitations'] ?? [],
    );

    final filtered = allExercises.where((e) {
      final matchesEquipment = equipment.isEmpty ||
          (e.equipment != null &&
              e.equipment!.isNotEmpty &&
              equipment.any((eq) =>
                  e.equipment!.toLowerCase().contains(eq.toLowerCase())));

      final safeFromPain = pain.every((p) => !e.nameHe.contains(p));
      final notAvoided = avoid.every((a) => !e.nameHe.contains(a));

      return matchesEquipment && safeFromPain && notAvoided;
    }).toList();

    final prioritized = preferredMuscles.isEmpty
        ? filtered
        : filtered.where((e) {
            return e.muscleGroups != null &&
                e.muscleGroups!
                    .any((muscle) => preferredMuscles.contains(muscle));
          }).toList();

    final usableExercises = prioritized.isNotEmpty ? prioritized : filtered;
    usableExercises.shuffle();

    final Map<String, List<Exercise>> days = {};
    int index = 0;

    for (int i = 0; i < daysPerWeek; i++) {
      final dayExercises =
          usableExercises.skip(index).take(exercisesPerDay).toList();
      days['יום ${_dayNames[i]}'] = dayExercises;
      index += exercisesPerDay;
    }

    return WorkoutPlan(
      days: days,
      difficulty: difficulty,
      goal: goal,
      totalExercises: usableExercises.length,
    );
  }

  static int _mapFrequencyToDays(String freq) {
    switch (freq) {
      case 'פעם-פעמיים':
        return 2;
      case '3-4 פעמים':
        return 4;
      case '5-6 פעמים':
        return 6;
      case 'כל יום':
        return 7;
      default:
        return _defaultDaysPerWeek;
    }
  }
}
