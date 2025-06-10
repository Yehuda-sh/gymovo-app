// lib/screens/welcome_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'questionnaire_screen.dart';
import '../screens/auth/login_screen.dart';
import '../data/local_data_store.dart';
import '../models/week_plan_model.dart';
import '../providers/week_plan_provider.dart';
import '../models/user_model.dart';
import '../services/plan_builder_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasPlan = false;
  bool _isAuthenticated = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _checkUserAndPlan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkUserAndPlan() async {
    final user = await LocalDataStore.getCurrentUser();
    final isAuthenticated =
        user != null && user.id.isNotEmpty && !(user.isGuest ?? false);
    bool hasPlan = false;
    if (isAuthenticated && user != null) {
      final plan = await LocalDataStore.getUserPlan(user.id);
      hasPlan = plan != null && plan.workouts.isNotEmpty;
    }
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuthenticated;
        _hasPlan = hasPlan;
        _isLoading = false;
      });
      _animationController.forward();
      if (isAuthenticated && hasPlan) {
        Future.microtask(() => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen())));
      }
    }
  }

  // יצירת משתמש דמו וקבלת 3 תוכניות שונות לפי ציוד מה־json בלבד
  Future<void> _skipAndCreateDemoPlan() async {
    setState(() => _isLoading = true);
    try {
      var user = await LocalDataStore.getCurrentUser();
      if (user == null || (user.isGuest ?? false)) {
        user = await LocalDataStore.createGuestUser();
      }

      final demoPlans = await PlanBuilderService.buildPlansForUser(user!);

      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'תוכנית דמו',
        description: 'תוכנית דמו מהירה (לפי סוגי ציוד שונים)',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: demoPlans,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      await LocalDataStore.saveUserPlan(user.id, plan);
      if (mounted) {
        await context.read<WeekPlanProvider>().refreshPlan();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('שגיאה ביצירת תוכנית דמו')),
        );
      }
    }
  }

  // יצירת משתמש דמו לבדיקה מהירה (DEV) – גם פה תמיד דרך PlanBuilderService
  Future<void> _quickTest() async {
    setState(() => _isLoading = true);
    try {
      final user = await LocalDataStore.createGuestUser();

      final demoPlans = await PlanBuilderService.buildPlansForUser(user);

      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'בדיקת מערכת',
        description: 'תוכנית אוטומטית לבדיקה מהירה',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: demoPlans,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      await LocalDataStore.saveUserPlan(user.id, plan);

      if (mounted) {
        await context.read<WeekPlanProvider>().refreshPlan();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בבדיקת מערכת: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildWelcomeText(colors),
                  const SizedBox(height: 18),
                  _buildSubtitle(colors),
                  const SizedBox(height: 18),
                  _buildFeaturesList(colors),
                  const SizedBox(height: 40),
                  if (!_isAuthenticated || !_hasPlan) ...[
                    _buildQuestionnaireButton(colors),
                    const SizedBox(height: 16),
                    _buildDemoButton(colors),
                    const SizedBox(height: 16),
                    _buildDevTestButton(colors),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 7, right: 5),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
            label: Text(
              'התחבר / הרשם',
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/gymovo_logo.png',
      height: 120,
    );
  }

  Widget _buildWelcomeText(AppColors colors) {
    return Text(
      'ברוך הבא ל־Gymovo',
      style: GoogleFonts.assistant(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colors.text,
      ),
    );
  }

  Widget _buildSubtitle(AppColors colors) {
    return Text(
      'הפוך כל אימון לחכם, מדויק ומותאם אישית!',
      textAlign: TextAlign.center,
      style: GoogleFonts.assistant(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.accent,
      ),
    );
  }

  Widget _buildFeaturesList(AppColors colors) {
    return Text(
      'מה מחכה לך באפליקציה?\n'
      '• שאלון התאמה קצר שמבוסס בינה מלאכותית\n'
      '• תוכנית אימונים שמתאימה במיוחד למטרות שלך\n'
      '• מעקב, התראות, גרפים, טיפים אישיים ועוד\n\n'
      'מלא את השאלון והמערכת תבנה עבורך את התוכנית המושלמת!',
      textAlign: TextAlign.right,
      style: GoogleFonts.assistant(
        fontSize: 16,
        color: colors.text.withOpacity(0.85),
      ),
    );
  }

  Widget _buildQuestionnaireButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.quiz, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QuestionnaireScreen()),
        ),
        label: Text(
          'התחל שאלון עכשיו',
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.skip_next, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.secondary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
        ),
        onPressed: _skipAndCreateDemoPlan,
        label: Text(
          'דלג וקבל תוכנית דמו',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDevTestButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.speed, color: Colors.white),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.accent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
        ),
        onPressed: _quickTest,
        label: Text(
          'בדיקת מערכת מהירה (dev)',
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
