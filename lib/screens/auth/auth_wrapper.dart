// lib/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import '../welcome/welcome_screen.dart';
import '../questionnaire/questionnaire_screen.dart';
import '../../models/user_model.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (_lastCheckedUserId != user?.id) {
      _checkUserStatus(user);
    }
  }

  Future<void> _checkUserStatus(UserModel? user) async {
    if (!mounted) return;

    final hasAnswers = user != null &&
        !user.isGuest &&
        user.questionnaireAnswers != null &&
        user.questionnaireAnswers!.isNotEmpty;

    if (_hasQuestionnaireAnswers != hasAnswers ||
        _lastCheckedUserId != user?.id ||
        _isLoading) {
      setState(() {
        _hasQuestionnaireAnswers = hasAnswers;
        _isLoading = false;
        _lastCheckedUserId = user?.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (_isLoading || authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authProvider.currentUser;

        if (user == null || user.isGuest) {
          return const WelcomeScreen();
        }

        if (_hasQuestionnaireAnswers) {
          return const HomeScreen();
        }

        return const QuestionnaireScreen();
      },
    );
  }
}
