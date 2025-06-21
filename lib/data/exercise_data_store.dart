// lib/data/exercise_data_store.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise.dart';

class ExerciseDataStore {
  static List<Exercise>? _cachedExercises;

  static Future<List<Exercise>> loadExercises() async {
    if (_cachedExercises != null) return _cachedExercises!;

    try {
      final data =
          await rootBundle.loadString('assets/data/workout_exercises.json');
      final List<dynamic> jsonList = json.decode(data);
      _cachedExercises =
          jsonList.map((json) => Exercise.fromJson(json)).toList();
      return _cachedExercises!;
    } catch (e) {
      // אפשר לטפל בשגיאה או להחזיר רשימה ריקה
      print('Error loading exercises: $e');
      return [];
    }
  }
}
