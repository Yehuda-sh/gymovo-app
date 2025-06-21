// lib/services/workout_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/workout_model.dart';
import '../models/exercise.dart';
import '../config/api_config.dart';
import '../data/local_data_store.dart';
import '../services/plan_builder_service.dart';
import '../services/workout_plan_builder.dart';

/// שירות לניהול אימונים עם תמיכה ב-API, מטמון ובניית תוכניות מותאמות אישית
class WorkoutService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  final http.Client _client;
  final Uuid _uuid = const Uuid();

  List<WorkoutModel>? _cachedWorkouts;
  DateTime? _lastCacheUpdate;

  WorkoutService({http.Client? client}) : _client = client ?? http.Client();

  bool get _isCacheValid {
    if (_cachedWorkouts == null || _lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request, {
    int retryCount = 0,
  }) async {
    try {
      final response = await request().timeout(_requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}');
    } on SocketException {
      throw const WorkoutServiceException('אין חיבור לאינטרנט');
    } on HttpException {
      rethrow;
    } catch (e) {
      if (retryCount < _maxRetries) {
        debugPrint('ניסיון ${retryCount + 1}/$_maxRetries נכשל, מנסה שוב...');
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _makeRequest(request, retryCount: retryCount + 1);
      }
      throw WorkoutServiceException('שגיאה בביצוע הבקשה: $e');
    }
  }

  Future<List<WorkoutModel>> getWorkouts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh && _isCacheValid) return _cachedWorkouts!;

      final response = await _makeRequest(
        () => _client.get(Uri.parse('$_baseUrl/workouts')),
      );

      final List<dynamic> data = json.decode(response.body);
      final workouts = data.map((json) => WorkoutModel.fromJson(json)).toList();

      _cachedWorkouts = workouts;
      _lastCacheUpdate = DateTime.now();

      return workouts;
    } catch (e) {
      debugPrint('שגיאה בטעינת אימונים מהשרת: $e');
      if (_cachedWorkouts != null) {
        debugPrint('מחזיר אימונים מהמטמון המקומי');
        return _cachedWorkouts!;
      }
      return await getWorkoutPrograms();
    }
  }

  Future<Map<String, Exercise>> getExerciseDetails(
      List<String> exerciseIds) async {
    if (exerciseIds.isEmpty) return {};

    try {
      final response = await _makeRequest(
        () => _client.post(
          Uri.parse('$_baseUrl/exercises/details'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'ids': exerciseIds}),
        ),
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final exercises = <String, Exercise>{};
      for (final entry in data.entries) {
        try {
          exercises[entry.key] = Exercise.fromJson(entry.value);
        } catch (e) {
          debugPrint('שגיאה בפיענוח תרגיל ${entry.key}: $e');
        }
      }
      return exercises;
    } catch (e) {
      debugPrint('שגיאה בטעינת פרטי תרגילים: $e');
      return {};
    }
  }

  Future<WorkoutModel> createWorkout(WorkoutModel workout) async {
    if (workout.title.trim().isEmpty) {
      throw const WorkoutServiceException('שם האימון לא יכול להיות ריק');
    }
    if (workout.exercises.isEmpty) {
      throw const WorkoutServiceException('האימון חייב לכלול לפחות תרגיל אחד');
    }

    final workoutToCreate = workout.copyWith(
      id: workout.id.isEmpty ? _uuid.v4() : workout.id,
      createdAt: workout.createdAt ?? DateTime.now(),
    );

    try {
      final response = await _makeRequest(
        () => _client.post(
          Uri.parse('$_baseUrl/workouts'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(workoutToCreate.toJson()),
        ),
      );
      final createdWorkout = WorkoutModel.fromJson(json.decode(response.body));
      _invalidateCache();
      return createdWorkout;
    } catch (e) {
      if (e is WorkoutServiceException) rethrow;
      throw WorkoutServiceException('שגיאה ביצירת אימון: $e');
    }
  }

  Future<WorkoutModel> updateWorkout(WorkoutModel workout) async {
    if (workout.id.isEmpty) {
      throw const WorkoutServiceException('מזהה האימון חסר');
    }
    final updatedWorkout = workout.copyWith(updatedAt: DateTime.now());
    try {
      final response = await _makeRequest(
        () => _client.put(
          Uri.parse('$_baseUrl/workouts/${workout.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedWorkout.toJson()),
        ),
      );
      final result = WorkoutModel.fromJson(json.decode(response.body));
      _invalidateCache();
      return result;
    } catch (e) {
      if (e is WorkoutServiceException) rethrow;
      throw WorkoutServiceException('שגיאה בעדכון אימון: $e');
    }
  }

  Future<bool> deleteWorkout(String workoutId) async {
    if (workoutId.trim().isEmpty) {
      throw const WorkoutServiceException('מזהה האימון חסר');
    }
    try {
      await _makeRequest(
        () => _client.delete(Uri.parse('$_baseUrl/workouts/$workoutId')),
      );
      _invalidateCache();
      return true;
    } catch (e) {
      debugPrint('שגיאה במחיקת אימון $workoutId: $e');
      return false;
    }
  }

  Future<WorkoutModel> duplicateWorkout(WorkoutModel original) async {
    final duplicated = original.copyWith(
      id: _uuid.v4(),
      title: '${original.title} (עותק)',
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    return await createWorkout(duplicated);
  }

  void _invalidateCache() {
    _cachedWorkouts = null;
    _lastCacheUpdate = null;
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
      debugPrint('שגיאה בטעינת אימונים מקומיים: $e');
      return _getDemoWorkouts();
    }
  }

  List<WorkoutModel> _getDemoWorkouts() {
    final now = DateTime.now();

    return [
      // דוגמה לאימון דמו 1
      WorkoutModel(
        id: _uuid.v4(),
        title: 'אימון מתחילים - יום א',
        description: 'אימון בסיסי למתחילים עם תרגילי משקל גוף',
        createdAt: now,
        date: now.subtract(const Duration(days: 2)),
        exercises: [
          ExerciseModel(
            id: _uuid.v4(),
            name: 'לחיצות דחיפה',
            sets: List.generate(3, (index) {
              return ExerciseSet(
                id: '${_uuid.v4()}_set_${index + 1}',
                weight: 0,
                reps: 8 + index * 2,
                restTime: 60,
                isCompleted: false,
                notes: index == 0 ? 'התחל בקצב איטי' : null,
              );
            }),
            notes: 'שמור על גב ישר ורגליים פשוטות',
          ),
          // ... הוסף תרגילים נוספים כאן ...
        ],
        metadata: {
          'difficulty': 'מתחילים',
          'goal': 'כוח בסיסי',
          'equipment': 'משקל גוף',
          'duration': 45,
          'muscleGroups': ['חזה', 'בטן', 'רגליים'],
          'calories': 200,
        },
      ),
      // דוגמה לאימון דמו 2
      WorkoutModel(
        id: _uuid.v4(),
        title: 'אימון מתחילים - יום ב',
        description: 'אימון משלים עם תרגילי גב וכתפיים',
        createdAt: now,
        date: now.subtract(const Duration(days: 1)),
        exercises: [
          ExerciseModel(
            id: _uuid.v4(),
            name: 'סופרמן',
            sets: List.generate(3, (index) {
              return ExerciseSet(
                id: '${_uuid.v4()}_set_${index + 1}',
                weight: 0,
                reps: 10,
                restTime: 60,
                isCompleted: false,
              );
            }),
            notes: 'הרם ידיים ורגליים בו זמנית',
          ),
          // ... תרגילים נוספים ...
        ],
        metadata: {
          'difficulty': 'מתחילים',
          'goal': 'יציבות ליבה',
          'equipment': 'משקל גוף',
          'duration': 35,
          'muscleGroups': ['גב', 'ליבה'],
          'calories': 150,
        },
      ),
    ];
  }

  // פונקציות עזר וחישובים נוספים (לפי הצורך) ...

  void dispose() {
    _client.close();
    _invalidateCache();
  }
}

class WorkoutServiceException implements Exception {
  final String message;
  const WorkoutServiceException(this.message);

  @override
  String toString() => 'WorkoutServiceException: $message';
}
