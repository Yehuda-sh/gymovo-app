// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/local_data_store.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  AuthState _state = AuthState.initial;
  String? _error;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  AuthState get state => _state;
  bool get isLoading => _state == AuthState.loading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser?.isGuest ?? false;
  bool get isDemo => _currentUser?.isDemo ?? false;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isInitialized => _isInitialized;

  // נתונים נוספים
  String get userDisplayName => _currentUser?.name ?? 'משתמש אנונימי';
  String get userEmail => _currentUser?.email ?? '';
  String? get userImageUrl => _currentUser?.imageUrl;

  // סטטיסטיקות משתמש
  Map<String, dynamic> get userStats {
    if (_currentUser == null) return {};

    return {
      'isGuest': isGuest,
      'isDemo': isDemo,
      'hasAge': _currentUser!.age != null,
      'hasImage': _currentUser!.imageUrl?.isNotEmpty == true,
      'userId': _currentUser!.id,
    };
  }

  // === אתחול ===
  Future<void> initialize() async {
    if (_isInitialized) return;

    await loadCurrentUser();
    _isInitialized = true;
  }

  // === טעינת משתמש נוכחי ===
  Future<void> loadCurrentUser() async {
    _setState(AuthState.loading);
    _clearError();

    try {
      _currentUser = await LocalDataStore.getCurrentUser();

      if (_currentUser == null) {
        // אין משתמש שמור - יצירת אורח
        _currentUser = await LocalDataStore.createGuestUser();
        _setState(AuthState.unauthenticated);
      } else if (_currentUser!.isGuest || _currentUser!.isDemo) {
        _setState(AuthState.unauthenticated);
      } else {
        _setState(AuthState.authenticated);
      }
    } catch (e) {
      _setError('שגיאה בטעינת המשתמש: $e');
    }
  }

  // === התחברות כמשתמש דמו ===
  Future<bool> loginAsDemoUser() async {
    _setState(AuthState.loading);
    _clearError();

    try {
      // בדיקה אם יש נתוני אורח לשמירה
      final shouldMigrateData = _currentUser?.isGuest == true;

      // מחיקת נתוני אורח אם קיימים ולא רוצים לשמור
      if (!shouldMigrateData) {
        await LocalDataStore.clearGuestData();
      }

      // טעינת משתמש דמו רנדומלי
      final demoUser = await LocalDataStore.getRandomDemoUser();
      if (demoUser == null) {
        throw Exception('לא נמצאו משתמשי דמו זמינים');
      }

      // שמירת מצב דמו
      await LocalDataStore.setDemoMode(true);

      // העברת נתוני אורח אם נדרש
      if (shouldMigrateData) {
        await LocalDataStore.migrateGuestDataToUser(demoUser.id);
      }

      // שמירת המשתמש הנוכחי
      _currentUser = demoUser;
      await LocalDataStore.saveCurrentUser(demoUser);

      _setState(AuthState.unauthenticated); // דמו זה עדיין לא authenticated
      return true;
    } catch (e) {
      _setError('שגיאה בהתחברות כמשתמש דמו: $e');
      return false;
    }
  }

  // === התחברות כמשתמש אורח ===
  Future<bool> loginAsGuest() async {
    _setState(AuthState.loading);
    _clearError();

    try {
      // מחיקת נתוני אורח קודמים אם קיימים
      await LocalDataStore.clearGuestData();

      // יצירת משתמש אורח חדש
      _currentUser = await LocalDataStore.createGuestUser();

      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('שגיאה בהתחברות כמשתמש אורח: $e');
      return false;
    }
  }

  // === הרשמת משתמש חדש ===
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    int? age,
    String? imageUrl,
  }) async {
    if (!_validateRegistrationInput(email, password, name)) {
      return false;
    }

    _setState(AuthState.loading);
    _clearError();

    try {
      // בדיקה אם המשתמש כבר קיים (נדלג על זה אם LocalDataStore לא תומך)
      // const existingUser = await LocalDataStore.getUserByEmail(email);
      // if (existingUser != null) {
      //   throw Exception('משתמש עם כתובת דוא"ל זו כבר קיים');
      // }

      // יצירת משתמש חדש
      final newUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email.toLowerCase().trim(),
        name: name.trim(),
        age: age,
        imageUrl: imageUrl,
        isGuest: false,
        isDemo: false,
      );

      // העברת נתוני אורח לחשבון החדש (אם יש)
      if (_currentUser?.isGuest == true) {
        await LocalDataStore.migrateGuestDataToUser(newUser.id);
      }

      // שמירת המשתמש החדש
      _currentUser = newUser;
      await LocalDataStore.saveCurrentUser(newUser);

      // מחיקת נתוני אורח אם קיימים
      await LocalDataStore.clearGuestData();

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('שגיאה בהרשמה: $e');
      return false;
    }
  }

  // === התחברות משתמש קיים ===
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!_validateLoginInput(email, password)) {
      return false;
    }

    _setState(AuthState.loading);
    _clearError();

    try {
      // חיפוש משתמש לפי דוא"ל (נדלג אם LocalDataStore לא תומך)
      // final user = await LocalDataStore.getUserByEmail(email.toLowerCase().trim());
      // if (user == null) {
      //   throw Exception('משתמש לא נמצא');
      // }

      // לעת עתה נניח שההתחברות מצליחה תמיד
      // בפרויקט אמיתי כאן תהיה בדיקה מול שרת

      // בדיקת סיסמה (כאן תוכל להוסיף הצפנה)
      // לעת עתה נניח שהסיסמה נכונה

      // יצירת משתמש מחובר (זמני - עד שיהיה מנגנון אמיתי)
      final user = UserModel(
        id: 'usr_login_${DateTime.now().millisecondsSinceEpoch}',
        email: email.toLowerCase().trim(),
        name: 'משתמש מחובר', // זמני
        isGuest: false,
        isDemo: false,
      );

      // העברת נתוני אורח אם יש
      if (_currentUser?.isGuest == true) {
        await LocalDataStore.migrateGuestDataToUser(user.id);
        await LocalDataStore.clearGuestData();
      }

      _currentUser = user;
      await LocalDataStore.saveCurrentUser(user);

      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('שגיאה בהתחברות: $e');
      return false;
    }
  }

  // === התנתקות ===
  Future<void> logout({bool clearAllData = false}) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final wasGuest = _currentUser?.isGuest ?? false;
      final wasDemo = _currentUser?.isDemo ?? false;

      if (clearAllData || wasGuest) {
        // מחיקת כל הנתונים
        await LocalDataStore.clearGuestData();
      }

      if (wasDemo) {
        // איפוס מזהה משתמש דמו אחרון
        await LocalDataStore.resetLastDemoUserId();
      }

      // מחיקת המשתמש הנוכחי
      _currentUser = null;
      await LocalDataStore.saveCurrentUser(UserModel.empty());

      // יצירת אורח חדש
      _currentUser = await LocalDataStore.createGuestUser();

      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('שגיאה בהתנתקות: $e');
    }
  }

  // === עדכון פרטי משתמש ===
  Future<bool> updateUserProfile({
    String? name,
    int? age,
    String? imageUrl,
    String? email,
  }) async {
    if (_currentUser == null) {
      _setError('אין משתמש מחובר');
      return false;
    }

    _setState(AuthState.loading);
    _clearError();

    try {
      // בדיקת דוא"ל חדש אם סופק (נדלג אם אין תמיכה)
      // if (email != null && email != _currentUser!.email) {
      //   final existingUser = await LocalDataStore.getUserByEmail(email);
      //   if (existingUser != null && existingUser.id != _currentUser!.id) {
      //     throw Exception('כתובת דוא"ל זו כבר בשימוש');
      //   }
      // }

      final updatedUser = _currentUser!.copyWith(
        name: name?.trim(),
        age: age,
        imageUrl: imageUrl,
        email: email?.toLowerCase().trim(),
      );

      _currentUser = updatedUser;
      await LocalDataStore.saveCurrentUser(updatedUser);

      _setState(_currentUser!.isGuest || _currentUser!.isDemo
          ? AuthState.unauthenticated
          : AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('שגיאה בעדכון הפרופיל: $e');
      return false;
    }
  }

  // === מחיקת חשבון ===
  Future<bool> deleteAccount() async {
    if (_currentUser == null || _currentUser!.isGuest) {
      await logout(clearAllData: true);
      return true;
    }

    _setState(AuthState.loading);
    _clearError();

    try {
      // מחיקת כל נתוני המשתמש (אם LocalDataStore תומך)
      // await LocalDataStore.deleteUser(_currentUser!.id);

      // לעת עתה פשוט נמחק את הנתונים המקומיים
      await LocalDataStore.clearGuestData();

      // יצירת אורח חדש
      _currentUser = await LocalDataStore.createGuestUser();

      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _setError('שגיאה במחיקת החשבון: $e');
      return false;
    }
  }

  // === שחזור סיסמה ===
  Future<bool> resetPassword(String email) async {
    _clearError();

    try {
      // לעת עתה נחזיר הצלחה (אין מנגנון שחזור אמיתי)
      // בפרויקט אמיתי כאן תהיה קריאה לשרת לשליחת דוא"ל

      // בדיקה בסיסית של פורמט דוא"ל
      if (!_isValidEmail(email)) {
        throw Exception('כתובת דוא"ל לא תקינה');
      }

      return true;
    } catch (e) {
      _setError('שגיאה בשחזור סיסמה: $e');
      return false;
    }
  }

  // === החלפת מצב משתמש ===
  Future<bool> switchToRegularAccount({
    required String email,
    required String password,
    required String name,
    int? age,
  }) async {
    if (_currentUser == null ||
        (!_currentUser!.isGuest && !_currentUser!.isDemo)) {
      _setError('פעולה זו זמינה רק למשתמשי אורח או דמו');
      return false;
    }

    return await register(
      email: email,
      password: password,
      name: name,
      age: age,
    );
  }

  // === פונקציות עזר פרטיות ===
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  bool _validateRegistrationInput(String email, String password, String name) {
    if (email.trim().isEmpty) {
      _setError('נא להזין כתובת דוא"ל');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('כתובת דוא"ל לא תקינה');
      return false;
    }

    if (password.length < 6) {
      _setError('הסיסמה חייבת להכיל לפחות 6 תווים');
      return false;
    }

    if (name.trim().isEmpty) {
      _setError('נא להזין שם');
      return false;
    }

    return true;
  }

  bool _validateLoginInput(String email, String password) {
    if (email.trim().isEmpty) {
      _setError('נא להזין כתובת דוא"ל');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('כתובת דוא"ל לא תקינה');
      return false;
    }

    if (password.trim().isEmpty) {
      _setError('נא להזין סיסמה');
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // === ניקוי משאבים ===
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // === איפוס מצב ===
  void reset() {
    _currentUser = null;
    _state = AuthState.initial;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}
