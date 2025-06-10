import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise.dart';

class ExerciseDataStore {
  static Future<List<Exercise>> loadExercises() async {
    final data =
        await rootBundle.loadString('assets/data/workout_exercises.json');
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Exercise.fromJson(json)).toList();
  }
}
