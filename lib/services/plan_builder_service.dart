// lib/services/plan_builder_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart' as workout;
import '../models/exercise.dart';
import '../providers/week_plan_provider.dart';

/// שירות מתקדם לבניית תכניות אימון מותאמות אישית
class PlanBuilderService {
  static List<Exercise>? _cachedExercises;
  static final Random _random = Random();

  // קבועים לקונפיגורציה
  static const int _defaultWorkoutDays = 3;
  static const int _defaultExercisesPerWorkout = 6;
  static const int _defaultSetsPerExercise = 3;
  static const int _defaultRepsPerSet = 10;
  static const int _defaultRestTime = 60;

  /// טוען את כל התרגילים מהקובץ JSON עם cache
  static Future<List<Exercise>> loadAllExercises() async {
    if (_cachedExercises != null) {
      return _cachedExercises!;
    }

    try {
      final jsonStr =
          await rootBundle.loadString('assets/data/workout_exercises.json');
      final List data = json.decode(jsonStr);
      _cachedExercises = data.map((item) => Exercise.fromJson(item)).toList();
      return _cachedExercises!;
    } catch (e) {
      throw Exception('שגיאה בטעינת תרגילים: $e');
    }
  }

  /// בונה תכנית אימון מותאמת אישית על בסיס תשובות השאלון
  static Future<List<workout.WorkoutModel>> buildFromAnswers(
    UserModel user,
    Map<String, dynamic> answers,
  ) async {
    try {
      final allExercises = await loadAllExercises();

      // חילוץ נתונים מהתשובות
      final preferences = _extractUserPreferences(answers);

      // סינון התרגילים לפי העדפות המשתמש
      final filteredExercises =
          _filterExercisesByPreferences(allExercises, preferences);

      if (filteredExercises.isEmpty) {
        throw Exception('לא נמצאו תרגילים מתאימים לפי ההעדפות שלך');
      }

      // קיבוץ תרגילים לפי קבוצות שרירים
      final groupedExercises = _groupByMuscleGroups(filteredExercises);

      // בניית תכנית האימון
      return _buildWorkoutPlan(user, preferences, groupedExercises);
    } catch (e) {
      throw Exception('שגיאה בבניית התכנית: $e');
    }
  }

  /// בונה תכנית דמו לפי סוג המשתמש
  static Future<List<workout.WorkoutModel>> buildDemoPlan(PlanType type) async {
    try {
      final allExercises = await loadAllExercises();

      final demoPreferences = _getDemoPreferences(type);
      final selectedExercises =
          _selectExercisesForDemo(allExercises, demoPreferences);

      return _buildDemoWorkoutPlan(type, selectedExercises);
    } catch (e) {
      throw Exception('שגיאה בבניית תכנית הדמו: $e');
    }
  }

  /// מנקה את הcache של התרגילים
  static void clearCache() {
    _cachedExercises = null;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Private Methods
  // ═══════════════════════════════════════════════════════════════════════════

  /// חילוץ העדפות המשתמש מתשובות השאלון
  static UserPreferences _extractUserPreferences(Map<String, dynamic> answers) {
    return UserPreferences(
      equipment:
          (answers['equipment_types'] as List<dynamic>?)?.cast<String>() ?? [],
      muscleGroups:
          (answers['main_muscles_focus'] as List<dynamic>?)?.cast<String>() ??
              [],
      avoidExercises:
          (answers['avoid_exercises'] as List<dynamic>?)?.cast<String>() ?? [],
      limitations:
          (answers['pain_or_limitations'] as List<dynamic>?)?.cast<String>() ??
              [],
      fitnessLevel: answers['fitness_level'] as String? ?? 'beginner',
      trainingDays:
          answers['training_days_per_week'] as int? ?? _defaultWorkoutDays,
      timePerSession: answers['time_per_session'] as int? ?? 60,
      goals: (answers['fitness_goals'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// סינון תרגילים לפי העדפות המשתמש
  static List<Exercise> _filterExercisesByPreferences(
    List<Exercise> exercises,
    UserPreferences preferences,
  ) {
    return exercises.where((exercise) {
      // בדיקת ציוד זמין
      if (!_isEquipmentAvailable(exercise, preferences.equipment)) {
        return false;
      }

      // בדיקת תרגילים להימנעות
      if (_shouldAvoidExercise(exercise, preferences.avoidExercises)) {
        return false;
      }

      // בדיקת הגבלות רפואיות
      if (_hasLimitations(exercise, preferences.limitations)) {
        return false;
      }

      // בדיקת רמת כושר
      if (!_matchesFitnessLevel(exercise, preferences.fitnessLevel)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// בדיקה אם הציוד הנדרש זמין
  static bool _isEquipmentAvailable(
      Exercise exercise, List<String> availableEquipment) {
    if (availableEquipment.isEmpty) return true;

    // התמודדות עם סוגי נתונים שונים של equipment
    String equipmentStr = exercise.equipment.name;

    if (equipmentStr.isEmpty) return true;

    return availableEquipment.any((equipment) =>
        equipmentStr.toLowerCase().contains(equipment.toLowerCase()));
  }

  /// בדיקה אם יש להימנע מהתרגיל
  static bool _shouldAvoidExercise(Exercise exercise, List<String> avoidList) {
    return avoidList.any(
        (avoid) => exercise.nameHe.toLowerCase().contains(avoid.toLowerCase()));
  }

  /// בדיקה אם יש הגבלות רפואיות
  static bool _hasLimitations(Exercise exercise, List<String> limitations) {
    for (final limitation in limitations) {
      if (exercise.nameHe.toLowerCase().contains(limitation.toLowerCase())) {
        return true;
      }

      // בדיקה בקבוצות שרירים אם קיימות
      final muscles = exercise.primaryMuscles;
      if (muscles.any((muscle) =>
          muscle.hebrewName.toLowerCase().contains(limitation.toLowerCase()))) {
        return true;
      }
    }
    return false;
  }

  /// בדיקה אם התרגיל מתאים לרמת הכושר
  static bool _matchesFitnessLevel(Exercise exercise, String fitnessLevel) {
    // כיון שאין metadata במודל, נניח שכל התרגילים מתאימים
    // ניתן להוסיף לוגיקה זו בעתיד על בסיס שם התרגיל או סוג

    // לוגיקה בסיסית לפי סוג התרגיל
    switch (fitnessLevel.toLowerCase()) {
      case 'beginner':
        // מתחילים - הימנעות מתרגילים מורכבים
        return !_isComplexExercise(exercise);
      case 'intermediate':
        return true; // כל התרגילים מתאימים לבינוניים
      case 'advanced':
        return true; // כל התרגילים מתאימים למתקדמים
      default:
        return true;
    }
  }

  /// בדיקה אם התרגיל מורכב (למתחילים)
  static bool _isComplexExercise(Exercise exercise) {
    final complexKeywords = ['deadlift', 'snatch', 'clean', 'מתים', 'חטיפה'];
    return complexKeywords.any((keyword) =>
        exercise.nameHe.toLowerCase().contains(keyword.toLowerCase()));
  }

  /// קיבוץ תרגילים לפי קבוצות שרירים
  static Map<String, List<Exercise>> _groupByMuscleGroups(
      List<Exercise> exercises) {
    final Map<String, List<Exercise>> grouped = {};

    for (final exercise in exercises) {
      // שימוש ב-primaryMuscles
      final muscles = exercise.primaryMuscles;

      for (final muscle in muscles) {
        grouped.putIfAbsent(muscle.hebrewName, () => []).add(exercise);
      }

      // אם אין קבוצת שרירים מוגדרת, שים ב"כללי"
      if (muscles.isEmpty) {
        grouped.putIfAbsent('כללי', () => []).add(exercise);
      }
    }

    return grouped;
  }

  /// בניית תכנית האימון המותאמת אישית
  static List<workout.WorkoutModel> _buildWorkoutPlan(
    UserModel user,
    UserPreferences preferences,
    Map<String, List<Exercise>> groupedExercises,
  ) {
    final workouts = <workout.WorkoutModel>[];
    final workoutDays = preferences.trainingDays.clamp(1, 7);

    // חילוק קבוצות השרירים בין ימי האימון
    final muscleDistribution = _distributeMuscleGroups(
      preferences.muscleGroups.isNotEmpty
          ? preferences.muscleGroups
          : groupedExercises.keys.toList(),
      workoutDays,
    );

    for (int day = 0; day < workoutDays; day++) {
      final targetMuscles = muscleDistribution[day] ?? [];
      final dayExercises = _selectExercisesForDay(
        groupedExercises,
        targetMuscles,
        preferences,
      );

      workouts.add(_createWorkoutModel(
        id: 'custom_day_$day',
        title: 'אימון מותאם אישית ${day + 1}',
        description: _generateWorkoutDescription(targetMuscles, preferences),
        day: day,
        exercises: dayExercises,
        metadata: {
          'muscles': targetMuscles.join(', '),
          'day': day + 1,
          'equipment': preferences.equipment.join(', '),
          'user_level': preferences.fitnessLevel,
          'estimated_time': preferences.timePerSession,
        },
      ));
    }

    return workouts;
  }

  /// חילוק קבוצות שרירים בין ימי האימון
  static Map<int, List<String>> _distributeMuscleGroups(
    List<String> muscleGroups,
    int workoutDays,
  ) {
    final distribution = <int, List<String>>{};

    if (muscleGroups.isEmpty) {
      // אם אין העדפה ספציפית, חלק באופן שווה
      final allMuscles = ['חזה', 'גב', 'כתפיים', 'רגליים', 'בטן', 'זרועות'];
      for (int i = 0; i < workoutDays; i++) {
        distribution[i] = [allMuscles[i % allMuscles.length]];
      }
    } else {
      // חלק את קבוצות השרירים המועדפות
      for (int i = 0; i < workoutDays; i++) {
        distribution[i] = [];
      }

      for (int i = 0; i < muscleGroups.length; i++) {
        final dayIndex = i % workoutDays;
        distribution[dayIndex]!.add(muscleGroups[i]);
      }
    }

    return distribution;
  }

  /// בחירת תרגילים ליום אימון ספציפי
  static List<Exercise> _selectExercisesForDay(
    Map<String, List<Exercise>> groupedExercises,
    List<String> targetMuscles,
    UserPreferences preferences,
  ) {
    final selectedExercises = <Exercise>[];
    final exercisesPerMuscle =
        (_defaultExercisesPerWorkout / targetMuscles.length).ceil();

    for (final muscle in targetMuscles) {
      final muscleExercises = groupedExercises[muscle] ?? [];
      if (muscleExercises.isNotEmpty) {
        muscleExercises.shuffle(_random);
        selectedExercises.addAll(
          muscleExercises.take(exercisesPerMuscle),
        );
      }
    }

    // אם אין מספיק תרגילים, השלם מתרגילים כלליים
    if (selectedExercises.length < _defaultExercisesPerWorkout) {
      final allExercises = groupedExercises.values
          .expand((list) => list)
          .where((ex) => !selectedExercises.contains(ex))
          .toList();

      allExercises.shuffle(_random);
      selectedExercises.addAll(
        allExercises
            .take(_defaultExercisesPerWorkout - selectedExercises.length),
      );
    }

    return selectedExercises.take(_defaultExercisesPerWorkout).toList();
  }

  /// יצירת מודל אימון
  static workout.WorkoutModel _createWorkoutModel({
    required String id,
    required String title,
    required String description,
    required int day,
    required List<Exercise> exercises,
    Map<String, dynamic>? metadata,
  }) {
    return workout.WorkoutModel(
      id: id,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      date: DateTime.now().add(Duration(days: day)),
      exercises: _convertToExerciseModels(exercises),
      metadata: metadata ?? {},
    );
  }

  /// המרת תרגילים למודלים של אימון
  static List<workout.ExerciseModel> _convertToExerciseModels(
      List<Exercise> exercises) {
    return exercises.map((exercise) {
      final sets = _generateSetsForExercise(exercise);

      return workout.ExerciseModel(
        id: exercise.id,
        name: exercise.nameHe,
        sets: sets,
        notes: exercise.instructionsHe.isNotEmpty
            ? exercise.instructionsHe.join('\n')
            : 'אין הוראות מיוחדות',
        videoUrl: exercise.videoUrl,
      );
    }).toList();
  }

  /// יצירת סטים לתרגיל
  static List<workout.ExerciseSet> _generateSetsForExercise(Exercise exercise) {
    // ניתן להתאים את מספר הסטים והחזרות לפי סוג התרגיל
    final difficulty = exercise.difficulty.name;
    final reps = _getRepsForDifficulty(difficulty);

    return List.generate(_defaultSetsPerExercise, (index) {
      return workout.ExerciseSet(
        id: '${exercise.id}_set_${index + 1}',
        weight: 0,
        reps: reps,
        restTime: _getRestTimeForExercise(exercise),
      );
    });
  }

  /// קביעת מספר חזרות לפי רמת קושי
  static int _getRepsForDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return 12;
      case 'medium':
        return 10;
      case 'hard':
        return 8;
      case 'very_hard':
        return 6;
      default:
        return _defaultRepsPerSet;
    }
  }

  /// קביעת זמן מנוחה לתרגיל
  static int _getRestTimeForExercise(Exercise exercise) {
    // ניתן להתאים לפי סוג התרגיל
    final type = exercise.type.name;

    switch (type) {
      case 'strength':
        return 90;
      case 'cardio':
        return 30;
      case 'flexibility':
        return 15;
      default:
        return _defaultRestTime;
    }
  }

  /// יצירת תיאור לאימון
  static String _generateWorkoutDescription(
    List<String> targetMuscles,
    UserPreferences preferences,
  ) {
    final muscleText = targetMuscles.isNotEmpty
        ? 'התמקדות ב${targetMuscles.join(' ו')}'
        : 'אימון כללי';

    final timeText = 'זמן אימון משוער: ${preferences.timePerSession} דקות';

    return '$muscleText\n$timeText';
  }

  /// קבלת העדפות לתכנית דמו
  static UserPreferences _getDemoPreferences(PlanType type) {
    switch (type) {
      case PlanType.demoFemale:
        return UserPreferences(
          equipment: ['משקולות', 'גומיות'],
          muscleGroups: ['רגליים', 'ישבן', 'בטן', 'זרועות'],
          avoidExercises: [],
          limitations: [],
          fitnessLevel: 'beginner',
          trainingDays: 3,
          timePerSession: 45,
          goals: ['חיטוב', 'כוח'],
        );
      case PlanType.demoMale:
        return UserPreferences(
          equipment: ['משקולות', 'מכונות'],
          muscleGroups: ['חזה', 'גב', 'כתפיים', 'זרועות'],
          avoidExercises: [],
          limitations: [],
          fitnessLevel: 'intermediate',
          trainingDays: 4,
          timePerSession: 60,
          goals: ['מסה', 'כוח'],
        );
      case PlanType.aiGenerated:
      case PlanType.custom:
        return UserPreferences(
          equipment: ['משקולות', 'גומיות'],
          muscleGroups: ['חזה', 'גב', 'רגליים'],
          avoidExercises: [],
          limitations: [],
          fitnessLevel: 'beginner',
          trainingDays: 3,
          timePerSession: 45,
          goals: ['כוח', 'סיבולת'],
        );
    }
  }

  /// בחירת תרגילים לתכנית דמו
  static List<Exercise> _selectExercisesForDemo(
    List<Exercise> allExercises,
    UserPreferences preferences,
  ) {
    final filtered = _filterExercisesByPreferences(allExercises, preferences);
    filtered.shuffle(_random);
    return filtered
        .take(_defaultExercisesPerWorkout * _defaultWorkoutDays)
        .toList();
  }

  /// בניית תכנית אימון דמו
  static List<workout.WorkoutModel> _buildDemoWorkoutPlan(
    PlanType type,
    List<Exercise> selectedExercises,
  ) {
    final workouts = <workout.WorkoutModel>[];
    final title = type == PlanType.demoFemale ? 'לנשים' : 'לגברים';

    for (int day = 0; day < _defaultWorkoutDays; day++) {
      final startIndex = day * _defaultExercisesPerWorkout;
      final endIndex = startIndex + _defaultExercisesPerWorkout;
      final dayExercises = selectedExercises.sublist(
        startIndex,
        endIndex.clamp(0, selectedExercises.length),
      );

      workouts.add(_createWorkoutModel(
        id: 'demo_day_$day',
        title: 'אימון דמו $title ${day + 1}',
        description: 'אימון לדוגמה שהוכן מראש\nמתאים למתחילים',
        day: day,
        exercises: dayExercises,
        metadata: {
          'demo': true,
          'day': day + 1,
          'type': type.toString(),
        },
      ));
    }

    return workouts;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Data Classes
// ═══════════════════════════════════════════════════════════════════════════

/// מחלקה לשמירת העדפות המשתמש
class UserPreferences {
  final List<String> equipment;
  final List<String> muscleGroups;
  final List<String> avoidExercises;
  final List<String> limitations;
  final String fitnessLevel;
  final int trainingDays;
  final int timePerSession;
  final List<String> goals;

  const UserPreferences({
    required this.equipment,
    required this.muscleGroups,
    required this.avoidExercises,
    required this.limitations,
    required this.fitnessLevel,
    required this.trainingDays,
    required this.timePerSession,
    required this.goals,
  });

  @override
  String toString() {
    return 'UserPreferences(equipment: $equipment, muscleGroups: $muscleGroups, '
        'fitnessLevel: $fitnessLevel, trainingDays: $trainingDays)';
  }
}
