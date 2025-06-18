import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/register/register_screen.dart';
import '../../data/local_data_store.dart';
import 'dart:math';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // פונקציה לקבלת אימייל רנדומלי ממשתמשי הדמו
  Future<String> _getRandomDemoEmail() async {
    try {
      final users = await LocalDataStore.loadDemoUsers();
      if (users.isNotEmpty) {
        final random = Random();
        final randomUser = users[random.nextInt(users.length)];
        return randomUser.email;
      }
    } catch (e) {
      debugPrint('Error loading demo users: $e');
    }
    // ברירת מחדל אם לא הצליח לטעון משתמשים
    return 'demo@gymovo.com';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 100,
                color: colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'ברוכים הבאים ל-Gymovo',
                style: GoogleFonts.assistant(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'האפליקציה המושלמת לניהול האימונים שלך',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  color: colors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // כפתור התחברות עם אימייל רנדומלי
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final randomEmail = await _getRandomDemoEmail();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LoginScreen(prefilledEmail: randomEmail),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shuffle),
                  label: Text(
                    'התחבר עם משתמש דמו',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // התחבר
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Text(
                    'התחבר',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // הרשמה
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(
                    'הרשם',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // הודעה מעודדת
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'התחבר או הירשם כדי לשמור את התקדמותך ולקבל תוכנית מותאמת אישית',
                        style: GoogleFonts.assistant(
                          fontSize: 14,
                          color: colors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
