// lib/features/workouts/providers/workouts_provider.dart
import 'package:flutter/foundation.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart';
import '../../../services/workout_service.dart';

enum WorkoutLoadingState { idle, loading, success, error }

class WorkoutsProvider with ChangeNotifier {
  final WorkoutService _workoutService;

  List<WorkoutModel> _workouts = [];
  WorkoutLoadingState _loadingState = WorkoutLoadingState.idle;
  String? _error;
  DateTime? _lastRefresh;

  // Cache for exercise details with expiration
  final Map<String, Exercise> _exerciseDetailsCache = {};
  final Map<String, DateTime> _exerciseCacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(hours: 1);

  // מסננים וחיפוש
  String _searchQuery = '';
  List<String> _selectedCategories = [];
  int? _maxDuration;

  WorkoutsProvider({WorkoutService? workoutService})
      : _workoutService = workoutService ?? WorkoutService();

  // Getters
  List<WorkoutModel> get workouts => _getFilteredWorkouts();
  List<WorkoutModel> get allWorkouts => List.unmodifiable(_workouts);
  WorkoutLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == WorkoutLoadingState.loading;
  bool get hasError => _loadingState == WorkoutLoadingState.error;
  String? get error => _error;
  bool get isEmpty =>
      _workouts.isEmpty && _loadingState != WorkoutLoadingState.loading;
  DateTime? get lastRefresh => _lastRefresh;

  // מסננים
  String get searchQuery => _searchQuery;
  List<String> get selectedCategories => List.unmodifiable(_selectedCategories);
  int? get maxDuration => _maxDuration;

  // סטטיסטיקות
  int get totalWorkouts => _workouts.length;
  List<String> get availableCategories {
    final categories = <String>{};
    for (final workout in _workouts) {
      // יצירת קטגוריות בהתבסס על סוג התרגילים
      for (final exercise in workout.exercises) {
        final words = exercise.name.split(' ');
        if (words.isNotEmpty) {
          // לקיחת המילה הראשונה כקטגוריה
          final category = words.first.trim();
          if (category.isNotEmpty) {
            categories.add(category);
          }
        }
      }

      // ניתן להוסיף קטגוריות נוספות לפי צורך:
      // אם יש שדה difficulty
      // if (workout.difficulty?.isNotEmpty == true) {
      //   categories.add(workout.difficulty!);
      // }
    }
    return categories.toList()..sort();
  }

  List<WorkoutModel> _getFilteredWorkouts() {
    List<WorkoutModel> filtered = List.from(_workouts);

    // חיפוש טקסט
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((workout) {
        return workout.title.toLowerCase().contains(query) ||
            workout.description?.toLowerCase().contains(query) == true ||
            workout.exercises
                .any((ex) => ex.name.toLowerCase().contains(query));
      }).toList();
    }

    // סינון לפי קטגוריות (סוגי תרגילים)
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((workout) {
        // בדיקה לפי סוג התרגילים
        final exerciseTypes = workout.exercises
            .map((e) => e.name.split(' ').first.trim())
            .where((type) => type.isNotEmpty)
            .toSet();
        return exerciseTypes.any((type) => _selectedCategories.contains(type));
      }).toList();
    }

    // סינון לפי משך זמן מקסימלי
    if (_maxDuration != null) {
      filtered = filtered.where((workout) {
        final estimatedDuration = _estimateWorkoutDuration(workout);
        return estimatedDuration <= _maxDuration!;
      }).toList();
    }

    return filtered;
  }

  int _estimateWorkoutDuration(WorkoutModel workout) {
    final totalSets =
        workout.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
    final avgRestTime = workout.exercises.isNotEmpty
        ? workout.exercises.first.sets.isNotEmpty
            ? workout.exercises.first.sets.first.restTime ?? 90
            : 90
        : 90;

    // הערכה: 1.5 דקות לסט + זמן מנוחה
    return ((totalSets * 1.5) + (totalSets * avgRestTime / 60)).round();
  }

  // ===== ניהול מצב =====
  void clearError() {
    if (_error != null) {
      _error = null;
      _loadingState = WorkoutLoadingState.idle;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void clearCategories() {
    _selectedCategories.clear();
    notifyListeners();
  }

  void setMaxDuration(int? duration) {
    _maxDuration = duration;
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedCategories.clear();
    _maxDuration = null;
    notifyListeners();
  }

  // ===== טעינת נתונים =====
  Future<void> loadWorkouts({bool forceRefresh = false}) async {
    if (_loadingState == WorkoutLoadingState.loading) return;

    // בדיקה אם נדרש רענון
    if (!forceRefresh && _workouts.isNotEmpty && _lastRefresh != null) {
      final timeSinceRefresh = DateTime.now().difference(_lastRefresh!);
      if (timeSinceRefresh < const Duration(minutes: 5)) {
        return; // לא צריך לרענן עדיין
      }
    }

    _setLoadingState(WorkoutLoadingState.loading);

    try {
      final workouts = await _workoutService.getWorkouts();
      _workouts = workouts;
      _lastRefresh = DateTime.now();
      _setLoadingState(WorkoutLoadingState.success);
    } catch (e) {
      _handleError('שגיאה בטעינת האימונים: ${e.toString()}', e);
    }
  }

  // ===== ניהול תרגילים =====
  Future<Map<String, Exercise>> getExerciseDetails(WorkoutModel workout) async {
    try {
      final exerciseIds = workout.exercises.map((e) => e.id).toList();
      final Map<String, Exercise> result = {};
      final List<String> idsToFetch = [];

      final now = DateTime.now();

      // בדיקת cache עם תוקף זמן
      for (final id in exerciseIds) {
        if (_exerciseDetailsCache.containsKey(id)) {
          final cacheTime = _exerciseCacheTimestamps[id];
          if (cacheTime != null &&
              now.difference(cacheTime) < _cacheExpiration) {
            result[id] = _exerciseDetailsCache[id]!;
          } else {
            // Cache פג תוקף
            _exerciseDetailsCache.remove(id);
            _exerciseCacheTimestamps.remove(id);
            idsToFetch.add(id);
          }
        } else {
          idsToFetch.add(id);
        }
      }

      // טעינת תרגילים חסרים
      if (idsToFetch.isNotEmpty) {
        final fetchedExercises =
            await _workoutService.getExerciseDetails(idsToFetch);

        // עדכון cache
        for (final entry in fetchedExercises.entries) {
          _exerciseDetailsCache[entry.key] = entry.value;
          _exerciseCacheTimestamps[entry.key] = now;
        }

        result.addAll(fetchedExercises);
      }

      return result;
    } catch (e) {
      debugPrint('Error getting exercise details: $e');
      _handleError('שגיאה בטעינת פרטי התרגילים', e);
      return {};
    }
  }

  // ===== ניהול אימונים =====
  Future<bool> deleteWorkout(String workoutId) async {
    final workoutIndex = _workouts.indexWhere((w) => w.id == workoutId);
    if (workoutIndex == -1) return false;

    final deletedWorkout = _workouts[workoutIndex];

    // עדכון אופטימסטי
    _workouts.removeAt(workoutIndex);
    notifyListeners();

    try {
      await _workoutService.deleteWorkout(workoutId);
      return true;
    } catch (e) {
      // החזרה במקרה של שגיאה
      _workouts.insert(workoutIndex, deletedWorkout);
      _handleError('שגיאה במחיקת האימון', e);
      return false;
    }
  }

  Future<WorkoutModel?> saveWorkout(WorkoutModel workout) async {
    try {
      WorkoutModel savedWorkout;

      if (workout.id.isEmpty) {
        // אימון חדש
        savedWorkout = await _workoutService.createWorkout(workout);
        _workouts.add(savedWorkout);
      } else {
        // עדכון אימון קיים
        savedWorkout = await _workoutService.updateWorkout(workout);
        final index = _workouts.indexWhere((w) => w.id == workout.id);
        if (index != -1) {
          _workouts[index] = savedWorkout;
        } else {
          _workouts.add(savedWorkout);
        }
      }

      _lastRefresh = DateTime.now();
      notifyListeners();
      return savedWorkout;
    } catch (e) {
      _handleError('שגיאה בשמירת האימון', e);
      return null;
    }
  }

  Future<WorkoutModel?> duplicateWorkout(WorkoutModel workout) async {
    try {
      final duplicatedWorkout = workout.copyWith(
        id: '',
        title: '${workout.title} - עותק',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await saveWorkout(duplicatedWorkout);
    } catch (e) {
      _handleError('שגיאה בשכפול האימון', e);
      return null;
    }
  }

  // ===== ארגון ומיון =====
  void reorderWorkouts(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;

    final workout = _workouts.removeAt(oldIndex);
    _workouts.insert(newIndex, workout);
    notifyListeners();

    // שמירת סדר (אופציונלי)
    _saveWorkoutOrder();
  }

  Future<void> _saveWorkoutOrder() async {
    try {
      final order = _workouts
          .asMap()
          .entries
          .map((entry) => {
                'id': entry.value.id,
                'order': entry.key,
              })
          .toList();

      // await _workoutService.saveWorkoutOrder(order);
    } catch (e) {
      debugPrint('Error saving workout order: $e');
    }
  }

  List<WorkoutModel> getWorkoutsByDuration(int minMinutes, int maxMinutes) {
    return _workouts.where((workout) {
      final estimatedMinutes = _estimateWorkoutDuration(workout);
      return estimatedMinutes >= minMinutes && estimatedMinutes <= maxMinutes;
    }).toList();
  }

  List<WorkoutModel> getRecentWorkouts({int limit = 5}) {
    final sorted = List<WorkoutModel>.from(_workouts)
      ..sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    return sorted.take(limit).toList();
  }

  List<WorkoutModel> getFavoriteWorkouts() {
    // אם אין שדה isFavorite, נחזיר רשימה ריקה או נוכל להשתמש בקריטריון אחר
    // לדוגמה: אימונים שעודכנו לאחרונה או בשימוש תכוף
    return [];

    // חלופות אם יש שדות אחרים:
    // return _workouts.where((w) => w.isStarred == true).toList(); // אם יש isStarred
    // return _workouts.where((w) => w.rating != null && w.rating! >= 4).toList(); // אם יש rating
  }

  // ===== פונקציות עזר =====
  WorkoutModel? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearExerciseCache() {
    _exerciseDetailsCache.clear();
    _exerciseCacheTimestamps.clear();
  }

  Future<void> refreshWorkouts() async {
    await loadWorkouts(forceRefresh: true);
  }

  void _setLoadingState(WorkoutLoadingState state) {
    _loadingState = state;
    if (state != WorkoutLoadingState.error) {
      _error = null;
    }
    notifyListeners();
  }

  void _handleError(String message, dynamic error) {
    _error = message;
    _loadingState = WorkoutLoadingState.error;
    debugPrint('WorkoutsProvider Error: $message - $error');
    notifyListeners();
  }

  @override
  void dispose() {
    _exerciseDetailsCache.clear();
    _exerciseCacheTimestamps.clear();
    super.dispose();
  }
}
