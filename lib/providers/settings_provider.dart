// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _languageKey = 'language_code';

  late SharedPreferences _prefs;

  String _languageCode = 'he';
  bool _notificationsEnabled = true;

  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;

  SettingsProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _languageCode = _prefs.getString(_languageKey) ?? 'he';
      _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
      notifyListeners();
    } catch (e) {
      // טיפול בשגיאות (לוג, fallback וכו')
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
    }
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    try {
      await _prefs.setBool(_notificationsKey, _notificationsEnabled);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error saving notifications setting: $e');
      }
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (_languageCode != languageCode) {
      _languageCode = languageCode;
      try {
        await _prefs.setString(_languageKey, languageCode);
        notifyListeners();
      } catch (e) {
        if (kDebugMode) {
          print('Error saving language setting: $e');
        }
      }
    }
  }
}
