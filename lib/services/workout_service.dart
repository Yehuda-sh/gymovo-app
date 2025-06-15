import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';
import '../models/exercise.dart';
import '../config/api_config.dart';
import 'package:uuid/uuid.dart';
import '../data/local_data_store.dart';
import 'package:flutter/foundation.dart';
import '../services/plan_builder_service.dart';
import '../services/workout_plan_builder.dart';

class WorkoutService {
  final String _baseUrl = ApiConfig.baseUrl;
  final http.Client _client;
  final _uuid = Uuid();

  WorkoutService({http.Client? client}) : _client = client ?? http.Client();

  // Get all workouts
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/workouts'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WorkoutModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load workouts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting workouts: $e');
    }
  }

  // Get exercise details
  Future<Map<String, Exercise>> getExerciseDetails(
      List<String> exerciseIds) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/exercises/details'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'ids': exerciseIds}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data
            .map((key, value) => MapEntry(key, Exercise.fromJson(value)));
      } else {
        throw Exception(
            'Failed to load exercise details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting exercise details: $e');
    }
  }

  // Create new workout
  Future<WorkoutModel> createWorkout(WorkoutModel workout) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/workouts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(workout.toJson()),
      );

      if (response.statusCode == 201) {
        return WorkoutModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating workout: $e');
    }
  }

  // Update existing workout
  Future<WorkoutModel> updateWorkout(WorkoutModel workout) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/workouts/${workout.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(workout.toJson()),
      );

      if (response.statusCode == 200) {
        return WorkoutModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating workout: $e');
    }
  }

  // Delete workout
  Future<void> deleteWorkout(String workoutId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/workouts/$workoutId'),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete workout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting workout: $e');
    }
  }

  // Dispose the HTTP client when done
  void dispose() {
    _client.close();
  }

  Future<List<WorkoutModel>> getWorkoutPrograms() async {
    try {
      final user = await LocalDataStore.getCurrentUser();
      if (user != null) {
        final plan = await LocalDataStore.getUserPlan(user.id);
        if (plan != null && plan.workouts.isNotEmpty) {
          return plan.workouts;
        }
      }
      return _getDemoWorkouts();
    } catch (e) {
      debugPrint('שגיאה בטעינת אימונים: $e');
      return _getDemoWorkouts();
    }
  }

  List<WorkoutModel> _getDemoWorkouts() {
    final now = DateTime.now();
    return [
      WorkoutModel(
        id: _uuid.v4(),
        title: 'אימון מתחילים',
        description: 'אימון בסיסי למתחילים',
        createdAt: DateTime.now(),
        date: now.subtract(const Duration(days: 2)),
        exercises: [
          ExerciseModel(
            id: _uuid.v4(),
            name: 'כפיפות בטן',
            sets: List.generate(3, (index) {
              return ExerciseSet(
                id: _uuid.v4(),
                weight: 0,
                reps: 12,
                restTime: 60,
                isCompleted: false,
                notes: 'לבצע לאט ובשליטה',
              );
            }),
            notes: 'כפיפות בטן בסיסיות לחיזוק שרירי הבטן',
          ),
        ],
        metadata: {
          'difficulty': 'מתחילים',
          'goal': 'כוח',
          'equipment': 'משקל גוף',
          'duration': 45,
        },
      ),
    ];
  }

  Future<List<WorkoutModel>> getFilteredWorkoutPrograms({
    String? difficulty,
    String? goal,
    String? equipment,
  }) async {
    final programs = await getWorkoutPrograms();
    return programs.where((program) {
      final metadata = program.metadata ?? {};
      if (difficulty != null && metadata['difficulty'] != difficulty) {
        return false;
      }
      if (goal != null && metadata['goal'] != goal) return false;
      if (equipment != null && metadata['equipment'] != equipment) return false;
      return true;
    }).toList();
  }

  /// בונה תוכנית מותאמת אישית לפי תשובות שאלון
  Future<List<WorkoutModel>> getCustomWorkoutPlanFromAnswers(
      Map<String, dynamic> answers) async {
    try {
      final allExercises = await PlanBuilderService.loadAllExercises();
      final plan = WorkoutPlanBuilder.buildCustomPlan(answers, allExercises);

      return plan.days.entries.map((entry) {
        final title = entry.key;
        return WorkoutModel(
          id: _uuid.v4(),
          title: 'אימון $title',
          description: 'אימון מותאם אישית ליום $title',
          createdAt: DateTime.now(),
          date: DateTime.now(),
          exercises: entry.value.map((ex) {
            return ExerciseModel(
              id: ex.id,
              name: ex.nameHe,
              notes: ex.instructionsHe.join('\n'),
              sets: [
                ExerciseSet(
                    id: '${ex.id}_s1', weight: 0, reps: 10, restTime: 60),
                ExerciseSet(
                    id: '${ex.id}_s2', weight: 0, reps: 10, restTime: 60),
                ExerciseSet(
                    id: '${ex.id}_s3', weight: 0, reps: 10, restTime: 60),
              ],
              videoUrl: ex.videoUrl,
            );
          }).toList(),
          metadata: {
            'difficulty': plan.difficulty,
            'goal': plan.goal,
            'duration': plan.averageExercisesPerDay * 8,
          },
        );
      }).toList();
    } catch (e) {
      debugPrint('שגיאה בבניית תוכנית מותאמת: $e');
      return _getDemoWorkouts();
    }
  }
}
