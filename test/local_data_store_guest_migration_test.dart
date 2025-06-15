import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymovo_app/data/local_data_store.dart';
import 'package:gymovo_app/models/week_plan_model.dart';
import 'package:gymovo_app/models/workout_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // ודא ש־SharedPreferences נקי לפני כל טסט
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    // נקה את כל הנתונים אחרי כל טסט
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  test('migrateGuestDataToUser migrates all guest data and deletes guest data',
      () async {
    // צור נתוני אורח
    final guestUser = await LocalDataStore.createGuestUser();
    final guestPlan = WeekPlanModel(
      id: 'plan1',
      userId: guestUser.id,
      title: 'תוכנית אורח',
      description: 'תוכנית לדוגמה',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      workouts: [],
      isActive: true,
      lastUpdated: DateTime.now(),
    );
    await LocalDataStore.saveUserPlan(guestUser.id, guestPlan);

    final guestWorkout = WorkoutModel(
      id: 'w1',
      title: 'אימון לדוגמה',
      description: 'אימון קרדיו לדוגמה',
      createdAt: DateTime.now(),
      date: DateTime.now(),
      exercises: [],
      notes: 'הערות לאימון',
      metadata: {
        'difficulty': 'beginner',
        'goal': 'weight_loss',
        'equipment': 'barbell',
        'duration': 30,
      },
    );
    await LocalDataStore.saveUserWorkoutHistory(guestUser.id, [guestWorkout]);

    // בצע מיגרציה
    final newUserId = 'usr_123456';
    try {
      await LocalDataStore.migrateGuestDataToUser(newUserId);
    } catch (e) {
      fail('מיגרציה נכשלה: $e');
    }

    // ודא שהנתונים עברו
    final migratedPlan = await LocalDataStore.getUserPlan(newUserId);
    expect(migratedPlan, isNotNull);
    expect(migratedPlan!.title, 'תוכנית אורח');
    expect(migratedPlan.userId, newUserId);
    expect(migratedPlan.description, 'תוכנית לדוגמה');

    final migratedHistory =
        await LocalDataStore.getUserWorkoutHistory(newUserId);
    expect(migratedHistory, isNotEmpty);
    expect(migratedHistory.first.id, 'w1');
    expect(migratedHistory.first.description, 'אימון קרדיו לדוגמה');
    expect(migratedHistory.first.notes, 'הערות לאימון');
    expect(migratedHistory.first.metadata?['difficulty'], 'beginner');
    expect(migratedHistory.first.metadata?['goal'], 'weight_loss');
    expect(migratedHistory.first.metadata?['equipment'], 'barbell');

    // ודא שאין נתוני אורח
    final guestPlanAfter = await LocalDataStore.getUserPlan(guestUser.id);
    expect(guestPlanAfter, isNull);
    final guestHistoryAfter =
        await LocalDataStore.getUserWorkoutHistory(guestUser.id);
    expect(guestHistoryAfter, isEmpty);
  });
}
