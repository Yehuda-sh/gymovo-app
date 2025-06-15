import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../data/local_data_store.dart';
import '../../services/plan_builder_service.dart';
import '../../models/week_plan_model.dart';
import 'questionnaire_screen.dart';
import '../home/home_screen.dart';

class QuestionnaireIntroScreen extends StatefulWidget {
  const QuestionnaireIntroScreen({super.key});

  @override
  State<QuestionnaireIntroScreen> createState() =>
      _QuestionnaireIntroScreenState();
}

class _QuestionnaireIntroScreenState extends State<QuestionnaireIntroScreen> {
  bool _isCreatingBasicPlan = false;

  Future<void> _createBasicPlan() async {
    setState(() => _isCreatingBasicPlan = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) return;

      // יצירת תוכנית בסיסית ללא שאלון
      final basicAnswers = {
        'goal': 'שיפור כושר גופני כללי',
        'frequency': '3-4 פעמים',
        'workout_duration': '30-45 דקות',
        'experience_level': 'מתחיל עם ניסיון בסיסי',
        'equipment': 'מכון כושר מקצועי',
      };

      // בניית תוכנית מהתשובות הבסיסיות
      final weekPlan =
          await PlanBuilderService.buildFromAnswers(user, basicAnswers);

      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'תוכנית בסיסית',
        description: 'תוכנית אימונים בסיסית למתחילים',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: weekPlan,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      // שמירת התוכנית
      await LocalDataStore.saveUserPlan(user.id, plan);

      // עדכון המשתמש עם תשובות בסיסיות
      final updatedUser = user.copyWith(
        questionnaireAnswers: Map<String, dynamic>.from(basicAnswers),
        profileLastUpdated: DateTime.now(),
      );
      await LocalDataStore.saveUser(updatedUser);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת תוכנית בסיסית: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingBasicPlan = false);
    }
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
              // אייקון
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // כותרת
              Text(
                'בואו ניצור תוכנית מותאמת בדיוק עבורך!',
                style: GoogleFonts.assistant(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // תיאור
              Text(
                'שאלון קצר של 2-3 דקות יעזור לנו לבנות תוכנית אימונים שמותאמת בדיוק לרמה שלך, למטרות שלך ולזמן הפנוי שלך.',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  color: colors.text,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // יתרונות השאלון
              _buildBenefitItem(
                icon: Icons.star_outline,
                title: 'תוכנית מותאמת אישית',
                description: 'תרגילים ועומסים המותאמים בדיוק לרמה שלך',
                colors: colors,
              ),

              const SizedBox(height: 16),

              _buildBenefitItem(
                icon: Icons.schedule,
                title: 'התאמה לזמן הפנוי',
                description: 'תוכנית שמתאימה למסגרת הזמן שלך',
                colors: colors,
              ),

              const SizedBox(height: 16),

              _buildBenefitItem(
                icon: Icons.trending_up,
                title: 'התקדמות מדודה',
                description: 'מעקב אחר התקדמות וגידול הדרגתי בעומסים',
                colors: colors,
              ),

              const SizedBox(height: 48),

              // כפתור למילוי השאלון
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'בואו נתחיל! (2-3 דקות)',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // כפתור לדילוג
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isCreatingBasicPlan ? null : _createBasicPlan,
                  child: _isCreatingBasicPlan
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.text.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'יוצר תוכנית בסיסית...',
                              style: GoogleFonts.assistant(
                                fontSize: 16,
                                color: colors.text.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'דלג ותתחיל עם תוכנית בסיסית',
                          style: GoogleFonts.assistant(
                            fontSize: 16,
                            color: colors.text.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'תוכל תמיד לחזור ולמלא את השאלון מההגדרות',
                style: GoogleFonts.assistant(
                  fontSize: 12,
                  color: colors.text.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
    required AppColors colors,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.assistant(
                  fontSize: 12,
                  color: colors.text.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
