// lib/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../data/local_data_store.dart';
import '../home_screen.dart';
import '../questionnaire_screen.dart';
import '../welcome_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _questionnaireCompleted = false;
  String? _lastCheckedUserId;

  @override
  void initState() {
    super.initState();
    // נטען בשלב הראשון בלי תלות במשתמש
    _checkQuestionnaireStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // נטען מחדש אם המשתמש התחלף
    if (authProvider.currentUser?.id != _lastCheckedUserId) {
      _checkQuestionnaireStatus();
    }
  }

  Future<void> _checkQuestionnaireStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? '';
    final completed = await LocalDataStore.isQuestionnaireCompleted(userId);
    setState(() {
      _questionnaireCompleted = completed;
      _isLoading = false;
      _lastCheckedUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading || authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.currentUser != null &&
        !(authProvider.currentUser?.isGuest ?? false)) {
      return _questionnaireCompleted
          ? const HomeScreen()
          : const QuestionnaireScreen();
    }

    // משתמש לא מחובר – תמיד WelcomeScreen (גם אם מילא שאלון)
    return const WelcomeScreen();
  }
}
