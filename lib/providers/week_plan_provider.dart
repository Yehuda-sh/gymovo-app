import 'package:flutter/foundation.dart';
import '../models/week_plan_model.dart';
import '../models/workout_model.dart'
    show WorkoutModel, ExerciseModel, ExerciseSet;
import '../models/user_model.dart' hide ExerciseSet;
import '../data/local_data_store.dart';
import '../services/plan_builder_service.dart';

enum PlanType { demoMale, demoFemale, aiGenerated, custom }

class WeekPlanProvider with ChangeNotifier {
  List<WorkoutModel> _weekPlan = [];
  UserModel? _user;
  String? _currentUserId;
  PlanType _currentPlanType = PlanType.demoMale;
  DateTime? _lastWorkoutDate;
  bool _isLoading = false;
  String? _error;

  List<WorkoutModel> get weekPlan => _weekPlan;
  UserModel? get user => _user;
  PlanType get currentPlanType => _currentPlanType;
  DateTime? get lastWorkoutDate => _lastWorkoutDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WeekPlanProvider() {
    init();
  }

  Future<void> init() async {
    try {
      final user = await LocalDataStore.getCurrentUser();
      if (user != null) {
        _currentUserId = user.id;
        _user = user;
        await _loadUserPlan();
      } else {
        await loadPlan(PlanType.demoMale);
      }
    } catch (e) {
      debugPrint('שגיאה באתחול WeekPlanProvider: $e');
      await loadPlan(PlanType.demoMale);
    }
  }

  Future<void> _loadUserPlan() async {
    if (_currentUserId == null) {
      await loadPlan(PlanType.demoMale);
      return;
    }

    final plan = await LocalDataStore.getUserPlan(_currentUserId!);
    if (plan != null) {
      _weekPlan = plan.workouts;
      _currentPlanType = PlanType.custom;
    } else {
      await loadPlan(PlanType.demoMale);
    }

    final history = await LocalDataStore.getUserWorkoutHistory(_currentUserId!);
    if (history.isNotEmpty) {
      history.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
      _lastWorkoutDate = history.first.date;
    }
    notifyListeners();
  }

  Future<void> saveWorkoutProgress({
    required String workoutId,
    required List<Map<String, dynamic>> sets,
    required int rating,
    String? feedback,
  }) async {
    if (_currentUserId == null) return;

    final workout = WorkoutModel(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: 'אימון אישי',
      description: 'אימון שנבנה עבורך',
      createdAt: DateTime.now(),
      date: DateTime.now(),
      exercises: sets
          .map((set) => ExerciseModel(
                id: '${DateTime.now().millisecondsSinceEpoch}_${set['id']}',
                name: set['name'],
                sets: [
                  ExerciseSet(
                    id: '${set['id']}_set_0',
                    weight: set['weight']?.toDouble(),
                    reps: set['reps'],
                    restTime: set['restTime'],
                    isCompleted: true,
                    notes: set['notes'],
                  )
                ],
                notes: set['description'],
              ))
          .toList(),
    );

    await LocalDataStore.saveUserWorkoutHistory(_currentUserId!, [workout]);
    _lastWorkoutDate = DateTime.now();
    notifyListeners();
  }

  Future<void> buildPlanFromAnswers(Map<String, dynamic> answers) async {
    if (_currentUserId == null || _user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final workouts =
          await PlanBuilderService.buildFromAnswers(_user!, answers);
      _weekPlan = workouts;
      _currentPlanType = PlanType.aiGenerated;
      await _saveWeekPlan();
    } catch (e) {
      _error = 'שגיאה בבניית תוכנית מותאמת: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPlan() async {
    if (_currentUserId != null) {
      await _loadUserPlan();
    } else {
      await loadPlan(_currentPlanType);
    }
  }

  Future<void> loadPlan(PlanType type) async {
    _currentPlanType = type;
    _isLoading = true;
    notifyListeners();

    try {
      final demoPlans = await PlanBuilderService.buildDemoPlan(type);
      _weekPlan = demoPlans;
    } catch (e) {
      _weekPlan = [];
      _error = 'שגיאה בטעינת תוכנית דמו: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPlan() async {
    _weekPlan = [];
    if (_currentUserId != null) {
      await LocalDataStore.deleteUserPlan(_currentUserId!);
    }
    _currentPlanType = PlanType.custom;
    notifyListeners();
  }

  Future<void> _saveWeekPlan() async {
    if (_currentUserId == null) {
      _error = 'אין משתמש מחובר';
      notifyListeners();
      return;
    }

    final plan = WeekPlanModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId!,
      title: 'תוכנית שבועית',
      description: 'תוכנית אימונים שבועית',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      workouts: _weekPlan,
      isActive: true,
      lastUpdated: DateTime.now(),
    );

    await LocalDataStore.saveUserPlan(_currentUserId!, plan);
  }

  Future<void> addWorkout(WorkoutModel workout) async {
    _weekPlan.add(workout);
    await _saveWeekPlan();
    notifyListeners();
  }
}
