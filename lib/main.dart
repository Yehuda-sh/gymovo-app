// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/questionnaire_results/questionnaire_results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GyMovo',
      debugShowCheckedModeBanner: false,
      locale: const Locale('he', 'IL'),
      theme: AppTheme.darkTheme, // שדרוג עיקרי!
      themeMode: ThemeMode.dark, // מוכן לעתיד
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('he', 'IL'),
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      home: const SplashScreenWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/questionnaireResults': (context) =>
            const QuestionnaireResultsScreen(),
      },
    );
  }
}

// SplashScreenWrapper נשאר בדיוק כמו אצלך.

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
