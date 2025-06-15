// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/workouts_provider.dart';
import 'providers/week_plan_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/questionnaire_results/questionnaire_results_screen.dart';

import 'providers/exercise_provider.dart';

import 'package:google_fonts/google_fonts.dart';
import 'providers/exercise_history_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-initialize only the essential AuthProvider
  final authProvider = AuthProvider();
  await authProvider.loadCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        // Only essential providers at app level
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // Other providers will be initialized in their respective screens
        // using ChangeNotifierProvider or ProxyProvider as needed
      ],
      child: const MyApp(),
    ),
  );
}

// Example of how to use providers in specific screens:
// In home_screen.dart:
/*
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeekPlanProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutsProvider()),
      ],
      child: HomeScreenContent(),
    );
  }
}
*/

// In workout_details_screen.dart:
/*
class WorkoutDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExerciseHistoryProvider(),
      child: WorkoutDetailsContent(),
    );
  }
}
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GyMovo',
      debugShowCheckedModeBanner: false,
      locale: const Locale('he', 'IL'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', 'US'), // תמיכה באנגלית
        Locale('ar', 'SA'), // תמיכה בערבית
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.colors.primary,
        ),
        textTheme: GoogleFonts.assistantTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreenWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/questionnaireResults': (context) =>
            const QuestionnaireResultsScreen(),
      },
    );
  }
}

// ניווט אוטומטי אחרי Splash לפי סטטוס התחברות
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1300)); // זמן Splash
    if (!mounted || _navigated) return;
    setState(() => _navigated = true);

    // שליפה מה־context ברגע שה־Provider קיים
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadCurrentUser(); // טעינת המשתמש הנוכחי

    if (!mounted) return; // בדיקה נוספת אחרי הטעינה

    if (authProvider.currentUser != null &&
        !(authProvider.currentUser?.isGuest ?? false)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SplashScreen();
      },
    );
  }
}
