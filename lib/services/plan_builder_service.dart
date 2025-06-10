import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart' as workout;
import '../models/exercise.dart';
import '../providers/week_plan_provider.dart';

class PlanBuilderService {
  static Future<List<Exercise>> loadAllExercises() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/workout_exercises.json');
    final List data = json.decode(jsonStr);
    return data.map((item) => Exercise.fromJson(item)).toList();
  }

  static Future<List<workout.WorkoutModel>> buildFromAnswers(
    UserModel user,
    Map<String, dynamic> answers,
  ) async {
    final allExercises = await loadAllExercises();
    final rand = Random();

    final equipmentAnswer = answers['equipment_types'] as List<String>? ?? [];
    final muscleFocus = answers['main_muscles_focus'] as List<String>? ?? [];
    final avoid = answers['avoid_exercises'] as List<String>? ?? [];
    final pain = answers['pain_or_limitations'] as List<String>? ?? [];

    final filtered = allExercises.where((e) {
      final matchesEquipment = equipmentAnswer.isEmpty ||
          e.equipment.any((eq) => equipmentAnswer
              .any((a) => eq.toLowerCase().contains(a.toLowerCase())));
      final isAllowed = avoid.every((a) => !e.nameHe.contains(a));
      final safe = pain.every((p) => !e.nameHe.contains(p));
      return matchesEquipment && isAllowed && safe;
    }).toList();

    final grouped = _groupByMuscle(filtered);

    List<workout.ExerciseModel> buildSets(List<Exercise> exercises) {
      return exercises
          .map((e) => workout.ExerciseModel(
                id: e.id,
                name: e.nameHe,
                sets: List.generate(
                  3,
                  (i) => workout.ExerciseSet(
                    id: '${e.id}_set_${i + 1}',
                    weight: 0,
                    reps: 10,
                    restTime: 60,
                  ),
                ),
                notes: e.instructionsHe.join('\n'),
                videoUrl: e.videoUrl,
              ))
          .toList();
    }

    final List<workout.WorkoutModel> days = [];

    for (int i = 0; i < 3; i++) {
      final List<Exercise> pool = muscleFocus.isEmpty
          ? grouped.values.expand((list) => list).cast<Exercise>().toList()
          : muscleFocus
              .expand((muscle) => grouped[muscle] ?? [])
              .cast<Exercise>()
              .toList();

      pool.shuffle(rand);
      final List<Exercise> picked = pool.take(6).toList();

      days.add(workout.WorkoutModel(
        id: 'custom_day_$i',
        title: 'אימון מותאם אישית ${i + 1}',
        description: 'אימון אוטומטי לפי העדפות המשתמש',
        date: DateTime.now().add(Duration(days: i)),
        exercises: buildSets(picked),
        metadata: {
          'muscles': muscleFocus.join(', '),
          'day': i + 1,
          'equipment': equipmentAnswer.join(', '),
        },
      ));
    }

    return days;
  }

  static Map<String, List<Exercise>> _groupByMuscle(List<Exercise> exercises) {
    final Map<String, List<Exercise>> map = {};
    for (var e in exercises) {
      for (var group in e.muscleGroups) {
        map.putIfAbsent(group, () => []).add(e);
      }
    }
    return map;
  }

  static Future<List<workout.WorkoutModel>> buildDemoPlan(PlanType type) async {
    final all = await loadAllExercises();
    final rand = Random();
    final title = type == PlanType.demoFemale ? 'לנשים' : 'לגברים';

    List<workout.ExerciseModel> buildSets(List<Exercise> exercises) {
      return exercises
          .map((e) => workout.ExerciseModel(
                id: e.id,
                name: e.nameHe,
                sets: List.generate(
                  3,
                  (i) => workout.ExerciseSet(
                    id: '${e.id}_set_${i + 1}',
                    weight: 0,
                    reps: 10,
                    restTime: 60,
                  ),
                ),
                notes: e.instructionsHe.join('\n'),
                videoUrl: e.videoUrl,
              ))
          .toList();
    }

    final List<workout.WorkoutModel> plans = [];
    for (int i = 0; i < 3; i++) {
      final selected = all..shuffle(rand);
      final chosen = selected.take(6).toList();
      plans.add(workout.WorkoutModel(
        id: 'demo_day_$i',
        title: 'אימון דמו $title ${i + 1}',
        description: 'אימון לדוגמה שהוכן מראש',
        date: DateTime.now().add(Duration(days: i)),
        exercises: buildSets(chosen),
        metadata: {'demo': true, 'day': i + 1},
      ));
    }

    return plans;
  }
}
