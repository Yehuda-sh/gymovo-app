// lib/services/workout_plan_builder.dart

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

  /// בונה תוכנית אימון מותאמת אישית על פי תשובות ושאלון
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

    final preferredMuscles =
        List<String>.from(answers['main_muscles_focus'] ?? []);
    final equipment = List<String>.from(answers['equipment_types'] ?? []);
    final avoid = List<String>.from(answers['avoid_exercises'] ?? []);
    final pain = List<String>.from(answers['pain_or_limitations'] ?? []);

    // סינון תרגילים לפי ציוד, הימנעות מפציעות ותרגילים לא רצויים
    final filtered = allExercises.where((exercise) {
      final matchesEquipment = equipment.isEmpty ||
          (exercise.equipment != null &&
              exercise.equipment.name.isNotEmpty &&
              equipment.any((eq) => exercise.equipment.name
                  .toLowerCase()
                  .contains(eq.toLowerCase())));

      final safeFromPain = pain.every((p) => !exercise.nameHe.contains(p));
      final notAvoided = avoid.every((a) => !exercise.nameHe.contains(a));

      return matchesEquipment && safeFromPain && notAvoided;
    }).toList();

    // העדפת תרגילים לפי קבוצות השרירים המועדפות
    final prioritized = preferredMuscles.isEmpty
        ? filtered
        : filtered.where((exercise) {
            return exercise.primaryMuscles
                .any((muscle) => preferredMuscles.contains(muscle.hebrewName));
          }).toList();

    final usableExercises = prioritized.isNotEmpty ? prioritized : filtered;

    usableExercises.shuffle();

    // חלוקה לימים על פי כמות האימונים בשבוע
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

  /// ממפה תדירות אימונים למספר ימים בשבוע
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
