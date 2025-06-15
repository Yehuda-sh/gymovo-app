// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../data/local_data_store.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser?.isGuest ?? false;
  bool get isDemo => _currentUser?.isDemo ?? false;

  // === טעינת משתמש נוכחי
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await LocalDataStore.getCurrentUser();
      _currentUser ??= await LocalDataStore.createGuestUser();
    } catch (e) {
      _error = 'שגיאה בטעינת המשתמש: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === התחברות כמשתמש דמו
  Future<void> loginAsDemoUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // מחיקת נתוני אורח אם קיימים
      await LocalDataStore.clearGuestData();

      // טעינת משתמש דמו רנדומלי
      final demoUser = await LocalDataStore.getRandomDemoUser();
      if (demoUser == null) {
        throw Exception('לא נמצאו משתמשי דמו');
      }

      // שמירת מצב דמו
      await LocalDataStore.setDemoMode(true);

      // שמירת המשתמש הנוכחי
      _currentUser = demoUser;
      await LocalDataStore.saveCurrentUser(demoUser);
    } catch (e) {
      _error = 'שגיאה בהתחברות כמשתמש דמו: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === התחברות כמשתמש אורח
  Future<void> loginAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // מחיקת נתוני אורח קודמים אם קיימים
      await LocalDataStore.clearGuestData();

      // יצירת משתמש אורח חדש
      _currentUser = await LocalDataStore.createGuestUser();
    } catch (e) {
      _error = 'שגיאה בהתחברות כמשתמש אורח: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === הרשמת משתמש חדש
  Future<void> register({
    required String email,
    required String password,
    required String name,
    int? age,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // יצירת משתמש חדש
      final newUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        age: age,
        isGuest: false,
        isDemo: false,
      );

      // העברת נתוני אורח לחשבון החדש (אם יש)
      await LocalDataStore.migrateGuestDataToUser(newUser.id);

      // שמירת המשתמש החדש
      _currentUser = newUser;
      await LocalDataStore.saveCurrentUser(newUser);

      // מחיקת נתוני אורח אם קיימים (ליתר ביטחון)
      await LocalDataStore.clearGuestData();
    } catch (e) {
      _error = 'שגיאה בהרשמה: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === התנתקות
  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser?.isGuest ?? false) {
        // אם המשתמש הוא אורח, מוחק את כל הנתונים שלו
        await LocalDataStore.clearGuestData();
      }

      // איפוס מזהה משתמש דמו אחרון
      await LocalDataStore.resetLastDemoUserId();

      // מחיקת המשתמש הנוכחי
      _currentUser = null;
      await LocalDataStore.saveCurrentUser(UserModel.empty());
    } catch (e) {
      _error = 'שגיאה בהתנתקות: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === עדכון פרטי משתמש
  Future<void> updateUserProfile({
    String? name,
    int? age,
    String? imageUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name,
        age: age,
        imageUrl: imageUrl,
      );

      _currentUser = updatedUser;
      await LocalDataStore.saveCurrentUser(updatedUser);
    } catch (e) {
      _error = 'שגיאה בעדכון הפרופיל: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
