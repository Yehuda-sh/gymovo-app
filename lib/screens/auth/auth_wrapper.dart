// lib/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/local_data_store.dart';
import '../home/home_screen.dart';
import '../questionnaire/questionnaire_screen.dart';
import '../welcome/welcome_screen.dart';
import '../questionnaire/questionnaire_intro_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _hasQuestionnaireAnswers = false;
  String? _lastCheckedUserId;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_lastCheckedUserId == null ||
        authProvider.currentUser?.id != _lastCheckedUserId) {
      _checkUserStatus();
    }
  }

  Future<void> _checkUserStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null && !user.isGuest) {
      // בדיקה אם למשתמש יש תשובות שאלון
      final hasAnswers = user.questionnaireAnswers != null &&
          user.questionnaireAnswers!.isNotEmpty;

      setState(() {
        _hasQuestionnaireAnswers = hasAnswers;
        _isLoading = false;
        _lastCheckedUserId = user.id;
      });
    } else {
      setState(() {
        _hasQuestionnaireAnswers = false;
        _isLoading = false;
        _lastCheckedUserId = user?.id;
      });
    }
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

    final user = authProvider.currentUser;

    // אם אין משתמש מחובר - לדף הברוכים הבאים
    if (user == null) {
      return const WelcomeScreen();
    }

    // אם זה משתמש אורח - לדף הברוכים הבאים (כדי לעודד התחברות)
    if (user.isGuest) {
      return const WelcomeScreen();
    }

    // משתמש רשום:
    // אם יש לו תשובות שאלון - לדף הבית
    if (_hasQuestionnaireAnswers) {
      return const HomeScreen();
    }

    // אם אין לו תשובות שאלון - לדף היכרות עם השאלון
    return const QuestionnaireIntroScreen();
  }
}
