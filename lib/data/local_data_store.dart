// lib/data/local_data_store.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/week_plan_model.dart';
import '../models/exercise_history.dart' as exercise_history;

class LocalDataStore {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';
  static const String _workoutHistoryKey = 'workout_history';
  static const String _userPlansKey = 'user_plans';
  static const String _guestIdKey = 'guest_id';
  static const String _demoModeKey = 'demo_mode';
  static const String _profileCompletionPromptKey =
      'profile_completion_prompt_shown';
  static const String _defaultAvatar = 'assets/avatars/default_avatar.png';
  static const String _exerciseHistoriesKey = 'exercise_histories';
  static const String _questionnaireCompletedKey = 'questionnaireCompleted';
  static const String _lastDemoUserIdKey = 'last_demo_user_id';

  // === יצירת guest_id ייחודי ושמירה
  static Future<String> createOrGetGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    String? guestId = prefs.getString(_guestIdKey);
    if (guestId == null) {
      guestId = 'gst_${Random().nextInt(99999999)}';
      await prefs.setString(_guestIdKey, guestId);
    }
    return guestId;
  }

// הוסף את הפונקציות הבאות לקובץ lib/data/local_data_store.dart

  // שמירת משתמש מעודכן
  static Future<void> saveUser(UserModel user) async {
    try {
      debugPrint('=== DEBUG: saveUser called ===');
      debugPrint('User ID: ${user.id}');
      debugPrint('User isGuest: ${user.isGuest}');
      debugPrint(
          'questionnaireAnswers before save: ${user.questionnaireAnswers}');
      debugPrint(
          'questionnaireAnswers keys: ${user.questionnaireAnswers?.keys.toList()}');

      final prefs = await SharedPreferences.getInstance();

      // עדכון הזמן האחרון
      final updatedUser = user.copyWith(
        profileLastUpdated: DateTime.now(),
      );

      debugPrint(
          'Updated user questionnaireAnswers: ${updatedUser.questionnaireAnswers}');

      final userMap = updatedUser.toMap();
      debugPrint('User toMap result keys: ${userMap.keys.toList()}');
      debugPrint(
          'questionnaire_answers in map: ${userMap['questionnaire_answers']}');

      // שמירה ב-SharedPreferences
      final jsonString = jsonEncode(userMap);
      debugPrint('JSON string length: ${jsonString.length}');
      // הדפס רק חלק מה-JSON אם הוא ארוך מדי
      if (jsonString.length > 500) {
        debugPrint(
            'JSON string (first 500 chars): ${jsonString.substring(0, 500)}...');
      } else {
        debugPrint('JSON string to save: $jsonString');
      }

      await prefs.setString('current_user', jsonString);

      // בדיקה מיידית אחרי שמירה
      final savedString = prefs.getString('current_user');
      if (savedString != null) {
        final savedMap = jsonDecode(savedString);
        debugPrint(
            'Immediately after save - parsed questionnaire_answers: ${savedMap['questionnaire_answers']}');
      } else {
        debugPrint(
            'ERROR: Could not retrieve saved user immediately after save!');
      }

      // אם זה לא משתמש אורח, שמור גם במאגר המשתמשים
      if (!user.isGuest) {
        final usersJson = prefs.getString('users') ?? '{}';
        final users = Map<String, dynamic>.from(jsonDecode(usersJson));
        users[user.id] = updatedUser.toMap();
        await prefs.setString('users', jsonEncode(users));
        debugPrint('Also saved to users collection');
      }

      debugPrint('User saved successfully: ${user.id}');
      debugPrint('================================');
    } catch (e, stackTrace) {
      debugPrint('Error saving user: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to save user: $e');
    }
  }

  // עדכון תשובות השאלון בלבד
  static Future<void> updateQuestionnaireAnswers(
    String userId,
    Map<String, dynamic> answers,
  ) async {
    try {
      debugPrint('=== DEBUG: updateQuestionnaireAnswers called ===');
      debugPrint('UserId: $userId');
      debugPrint('Answers to update: $answers');
      debugPrint('Answers keys: ${answers.keys.toList()}');

      final user = await getCurrentUser();
      debugPrint('Current user found: ${user != null}');
      debugPrint('Current user ID matches: ${user?.id == userId}');

      if (user != null && user.id == userId) {
        debugPrint('Updating user with new questionnaire answers...');
        final updatedUser = user.copyWith(
          questionnaireAnswers: answers,
          profileLastUpdated: DateTime.now(),
        );
        debugPrint(
            'Updated user questionnaireAnswers: ${updatedUser.questionnaireAnswers}');
        await saveUser(updatedUser);
        debugPrint('User saved successfully via updateQuestionnaireAnswers');
      } else {
        debugPrint(
            'ERROR: User not found or ID mismatch in updateQuestionnaireAnswers');
      }
      debugPrint('================================================');
    } catch (e, stackTrace) {
      debugPrint('Error updating questionnaire answers: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to update questionnaire answers: $e');
    }
  }

  // === יצירת משתמש אורח ושמירתו כמשתמש נוכחי
  static Future<UserModel> createGuestUser() async {
    final guestId = await createOrGetGuestId();
    final guestUser = UserModel(
      id: guestId,
      email: '',
      name: 'משתמש אורח',
      isGuest: true,
    );
    await saveCurrentUser(guestUser);
    return guestUser;
  }

  // === בדיקה אם המשתמש הנוכחי הוא אורח
  static Future<bool> isGuestUser() async {
    final user = await getCurrentUser();
    return user?.isGuest ?? false;
  }

  // === בדיקה אם המשתמש הנוכחי הוא דמו
  static Future<bool> isDemoUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_demoModeKey) ?? false;
  }

  // === מחיקת guest_id ונתוני אורח
  static Future<void> clearGuestData() async {
    final prefs = await SharedPreferences.getInstance();
    final guestId = await createOrGetGuestId();

    // מחיקת תוכנית אימונים
    await deleteUserPlan(guestId);

    // מחיקת היסטוריית אימונים
    await prefs.remove('${_workoutHistoryKey}_$guestId');

    // מחיקת guest_id
    await prefs.remove(_guestIdKey);

    // מחיקת משתמש נוכחי אם הוא אורח
    final currentUser = await getCurrentUser();
    if (currentUser?.isGuest ?? false) {
      await prefs.remove(_currentUserKey);
    }
  }

  // === מחיקת תוכנית אימונים למשתמש מסוים
  static Future<void> deleteUserPlan(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_userPlansKey}_$userId');
  }

  // === שמירת משתמש נוכחי
  static Future<void> saveCurrentUser(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, json.encode(user.toMap()));
    }
  }

  // === טעינת משתמש נוכחי
  static Future<UserModel?> getCurrentUser() async {
    try {
      debugPrint('=== DEBUG: getCurrentUser called ===');
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      debugPrint(
          'Raw JSON from SharedPreferences: ${userJson?.substring(0, userJson.length > 200 ? 200 : userJson.length)}${userJson != null && userJson.length > 200 ? '...' : ''}');

      if (userJson == null) {
        debugPrint('getCurrentUser: No user data found in SharedPreferences');
        return null;
      }

      final userMap = json.decode(userJson);
      debugPrint('Parsed user map keys: ${userMap.keys.toList()}');
      debugPrint(
          'questionnaire_answers from parsed map: ${userMap['questionnaire_answers']}');

      final user = UserModel.fromMap(userMap);
      debugPrint(
          'UserModel created - questionnaireAnswers: ${user.questionnaireAnswers}');
      debugPrint(
          'UserModel questionnaireAnswers keys: ${user.questionnaireAnswers?.keys.toList()}');
      debugPrint('=====================================');

      return user;
    } catch (e) {
      debugPrint('Error loading current user: $e');
      return null;
    }
  }

  // === שמירת תוכנית אימונים למשתמש
  static Future<void> saveUserPlan(String userId, WeekPlanModel plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_userPlansKey}_$userId',
      json.encode(plan.toMap()),
    );
  }

  // === טעינת תוכנית אימונים למשתמש
  static Future<WeekPlanModel?> getUserPlan(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final planJson = prefs.getString('${_userPlansKey}_$userId');
    if (planJson == null) return null;
    try {
      return WeekPlanModel.fromMap(json.decode(planJson));
    } catch (e) {
      debugPrint('Error loading user plan: $e');
      return null;
    }
  }

  // === שמירת היסטוריית אימונים למשתמש
  static Future<void> saveUserWorkoutHistory(
      String userId, List<WorkoutModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_workoutHistoryKey}_$userId',
      json.encode(history.map((w) => w.toMap()).toList()),
    );
  }

  // === טעינת היסטוריית אימונים למשתמש
  static Future<List<WorkoutModel>> getUserWorkoutHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('${_workoutHistoryKey}_$userId');
    if (historyJson == null) return [];
    try {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList
          .map((w) => WorkoutModel.fromMap(w as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading workout history: $e');
      return [];
    }
  }

  // === טעינת משתמשי דמו מה־JSON המקומי
  static Future<List<UserModel>> loadDemoUsers() async {
    try {
      debugPrint('=== DEBUG: loadDemoUsers called ===');
      final String jsonString =
          await rootBundle.loadString('assets/data/demo_users.json');
      debugPrint('Loaded JSON string length: ${jsonString.length}');

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      debugPrint('JSON data keys: ${jsonData.keys.toList()}');

      final List<dynamic> usersJson = jsonData['users'] as List<dynamic>;
      debugPrint('Found ${usersJson.length} demo users');

      final List<UserModel> users = [];
      for (var i = 0; i < usersJson.length; i++) {
        try {
          final userJson = usersJson[i];
          debugPrint('Processing user $i:');
          debugPrint('User JSON keys: ${userJson.keys.toList()}');
          debugPrint('User ID: ${userJson['id']}');

          if (userJson['id'] == null) {
            debugPrint('ERROR: User $i has null ID, skipping');
            continue;
          }

          final user = UserModel.fromMap(userJson);
          users.add(user);
          debugPrint('Successfully loaded user ${user.id}');
        } catch (e) {
          debugPrint('Error processing user $i: $e');
          continue;
        }
      }

      debugPrint('Successfully loaded ${users.length} demo users');
      debugPrint('=====================================');
      return users;
    } catch (e, stackTrace) {
      debugPrint('Error loading demo users: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // === איפוס last_demo_user_id בהתנתקות
  static Future<void> resetLastDemoUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDemoUserIdKey);
    debugPrint('last_demo_user_id RESET');
  }

  // === קבלת משתמש דמו רנדומלי (לא חוזר על האחרון)
  static Future<UserModel?> getRandomDemoUser() async {
    final users = await loadDemoUsers();
    if (users.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getString(_lastDemoUserIdKey);
    debugPrint('last_demo_user_id before pick: $lastId');
    // סנן את המשתמש האחרון אם יש יותר ממשתמש אחד
    final filtered = (lastId != null && users.length > 1)
        ? users.where((u) => u.id != lastId).toList()
        : users;
    final chosen = filtered[Random().nextInt(filtered.length)];
    debugPrint('Picked demo user: ${chosen.id} (${chosen.name})');
    await prefs.setString(_lastDemoUserIdKey, chosen.id);
    debugPrint('last_demo_user_id after pick: ${chosen.id}');
    return chosen;
  }

  // === שמירת מצב דמו
  static Future<void> setDemoMode(bool isDemo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, isDemo);
  }

  // === בדיקה אם להציג פופ־אפ השלמת פרופיל
  static Future<bool> shouldShowProfileCompletionPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final user = await getCurrentUser();
    if (user == null) return false;
    final promptShown = prefs.getBool(_profileCompletionPromptKey) ?? false;
    if (promptShown) return false;
    if (!user.isProfileComplete) {
      await prefs.setBool(_profileCompletionPromptKey, true);
      return true;
    }
    return false;
  }

  // === אווטאר ברירת מחדל
  static String getDefaultAvatarPath() {
    return _defaultAvatar;
  }

  // === טעינת משתמש דמו עם כל הדאטה
  static Future<UserModel?> loadDemoUserWithData(String userId) async {
    final users = await loadDemoUsers();
    final user = users.firstWhere(
      (u) => u.id == userId,
      orElse: () => UserModel.empty(),
    );
    if (user.isEmpty) return null;

    // טעינת תוכנית אימונים
    final plan = await getUserPlan(userId);
    if (plan != null) {
      // עדכון המשתמש עם התוכנית
      return user.copyWith(
        preferences: user.preferences,
      );
    }

    return user;
  }

  // === מיגרציה של נתוני אורח למשתמש רשום
  static Future<void> migrateGuestDataToUser(String userId) async {
    final guestId = await createOrGetGuestId();
    if (guestId == userId) return; // אין צורך במיגרציה

    try {
      // העברת תוכנית אימונים
      final guestPlan = await getUserPlan(guestId);
      if (guestPlan != null) {
        await saveUserPlan(userId, guestPlan);
        await deleteUserPlan(guestId);
      }

      // העברת היסטוריית אימונים
      final guestHistory = await getUserWorkoutHistory(guestId);
      if (guestHistory.isNotEmpty) {
        await saveUserWorkoutHistory(userId, guestHistory);
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('${_workoutHistoryKey}_$guestId');
      }

      // מחיקת guest_id
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestIdKey);
    } catch (e) {
      debugPrint('Error during guest data migration: $e');
      // אפשר להוסיף כאן דיווח ל-Crashlytics בעתיד
    }
  }

  static Future<List<exercise_history.ExerciseHistory>>
      getExerciseHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historiesJson = prefs.getString(_exerciseHistoriesKey);
    if (historiesJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(historiesJson);
      return decoded
          .map((item) => exercise_history.ExerciseHistory.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error loading exercise histories: $e');
      return [];
    }
  }

  static Future<void> saveExerciseHistory(
      exercise_history.ExerciseHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final histories = await getExerciseHistories();

      final index =
          histories.indexWhere((h) => h.exerciseId == history.exerciseId);
      if (index >= 0) {
        histories[index] = history;
      } else {
        histories.add(history);
      }

      await prefs.setString(_exerciseHistoriesKey,
          json.encode(histories.map((h) => h.toMap()).toList()));
    } catch (e) {
      debugPrint('Error saving exercise history: $e');
      // אפשר להוסיף כאן דיווח ל-Crashlytics בעתיד
    }
  }

  // === בדיקה אם השאלון הושלם למשתמש
  static Future<bool> isQuestionnaireCompleted(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String prefsKey = userId.isNotEmpty
        ? '${_questionnaireCompletedKey}_$userId'
        : '${_questionnaireCompletedKey}_guest';
    return prefs.getBool(prefsKey) ?? false;
  }

  // === שמירת סטטוס השלמת השאלון
  static Future<void> setQuestionnaireCompleted(
      String userId, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    String prefsKey = userId.isNotEmpty
        ? '${_questionnaireCompletedKey}_$userId'
        : '${_questionnaireCompletedKey}_guest';
    await prefs.setBool(prefsKey, completed);
  }

  // === מחיקת סטטוס השלמת השאלון
  static Future<void> clearQuestionnaireStatus(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String prefsKey = userId.isNotEmpty
        ? '${_questionnaireCompletedKey}_$userId'
        : '${_questionnaireCompletedKey}_guest';
    await prefs.remove(prefsKey);
  }

  // === מחיקת כל הנתונים
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // === מחיקת נתוני משתמש
  static Future<void> clearUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await deleteUserPlan(userId);
    await prefs.remove('${_workoutHistoryKey}_$userId');
    await clearQuestionnaireStatus(userId);
  }

  // === טעינת תוכנית דמו למשתמש
  static Future<WeekPlanModel?> getDemoPlanForUser(String userId) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/demo_plans.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> plansJson = jsonData['plans'] as List<dynamic>;

      // מציאת התוכנית המתאימה למשתמש
      final planJson = plansJson.firstWhere(
        (p) => p['user_id'] == userId,
        orElse: () => null,
      );

      if (planJson == null) return null;
      return WeekPlanModel.fromMap(planJson);
    } catch (e) {
      debugPrint('Error loading demo plan: $e');
      return null;
    }
  }
}
