// lib/screens/questionnaire/screens/enhanced_questionnaire_results_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/questionnaire_analytics.dart';
import '../../../data/local_data_store.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../screens/home/home_screen.dart';
import 'enhanced_questionnaire_screen.dart';

class EnhancedQuestionnaireResultsScreen extends StatelessWidget {
  const EnhancedQuestionnaireResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: FutureBuilder<UserModel?>(
        future: LocalDataStore.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          final user = snapshot.data;
          final hasAnswers = user?.questionnaireAnswers != null &&
              user!.questionnaireAnswers!.isNotEmpty;

          if (!hasAnswers) {
            return _buildNoDataState(context, colors);
          }

          final answers = user!.questionnaireAnswers!;
          final analysis = QuestionnaireAnalytics.analyzeAnswers(answers);
          final tips = QuestionnaireAnalytics.generatePersonalizedTips(answers);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, colors, user),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(context, colors, user, analysis),
                    _buildAnalyticsSection(context, colors, analysis),
                    _buildAnswersSection(context, colors, answers),
                    _buildRecommendationsSection(context, colors, analysis),
                    _buildPersonalizedTipsSection(context, colors, tips),
                    _buildActionSection(context, colors),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context, AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
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
          const SizedBox(height: 24),
          Text(
            'לא נמצאו נתוני שאלון',
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'מלא את השאלון כדי לקבל תוכנית מותאמת אישית',
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: colors.text.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(
              'התחל שאלון',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const EnhancedQuestionnaireScreen(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppColors colors, UserModel user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: colors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'הפרופיל שלי',
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.home, color: colors.text),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, AppColors colors,
      UserModel user, Map<String, dynamic> analysis) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.1),
            colors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // אווטר
          Hero(
            tag: 'user_avatar',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withValues(alpha: 0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: GoogleFonts.assistant(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // שם המשתמש
          Text(
            user.name.isNotEmpty ? user.name : 'משתמש אורח',
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
          ),

          const SizedBox(height: 8),

          // סטטוס כושר
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'רמת כושר: ${analysis['fitness_level'] ?? 'לא נקבע'}',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // סטטיסטיקות מהירות
          _buildQuickStats(colors, user.questionnaireAnswers!),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppColors colors, Map<String, dynamic> answers) {
    final stats = [
      {
        'label': 'BMI',
        'value': _calculateBMI(answers['height'], answers['weight'])
                ?.toStringAsFixed(1) ??
            '-',
        'icon': Icons.analytics_outlined,
      },
      {
        'label': 'ימי אימון',
        'value': _extractFrequency(answers['frequency']),
        'icon': Icons.calendar_today,
      },
      {
        'label': 'דקות לאימון',
        'value': _extractDuration(answers['workout_duration']),
        'icon': Icons.timer,
      },
      {
        'label': 'רמת ניסיון',
        'value': _shortenExperience(answers['experience_level']),
        'icon': Icons.trending_up,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                stat['icon'] as IconData,
                color: colors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat['value'] as String,
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Text(
              stat['label'] as String,
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticsSection(
      BuildContext context, AppColors colors, Map<String, dynamic> analysis) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insights,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ניתוח אישי',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // BMI וקטגוריה
          if (analysis['bmi'] != null)
            _buildAnalyticsRow(
              colors,
              'מדד מסת גוף (BMI)',
              '${analysis['bmi'].toStringAsFixed(1)} - ${analysis['bmi_category']}',
              _getBMIColor(analysis['bmi']),
              Icons.monitor_weight_outlined,
            ),

          const SizedBox(height: 12),

          // זמן אימון שבועי
          if (analysis['weekly_training_time'] != null)
            _buildAnalyticsRow(
              colors,
              'זמן אימון שבועי',
              '${analysis['weekly_training_time']} דקות',
              colors.primary,
              Icons.schedule,
            ),

          const SizedBox(height: 12),

          // רמת מוטיבציה
          if (analysis['motivation_level'] != null)
            _buildAnalyticsRow(
              colors,
              'רמת מוטיבציה',
              analysis['motivation_level'],
              _getMotivationColor(analysis['motivation_level']),
              Icons.psychology,
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(AppColors colors, String label, String value,
      Color valueColor, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.text.withValues(alpha: 0.6)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: colors.text.withValues(alpha: 0.8),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: valueColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswersSection(
      BuildContext context, AppColors colors, Map<String, dynamic> answers) {
    final categories = {
      'פרטים אישיים': ['age', 'gender', 'height', 'weight'],
      'מטרות ויעדים': ['goal', 'goal_timeline', 'body_focus'],
      'זמינות ואימון': ['frequency', 'workout_duration', 'equipment'],
      'ניסיון ובריאות': [
        'experience_level',
        'exercise_break',
        'health_limitations'
      ],
      'העדפות': [
        'workout_style_preference',
        'avoid_exercises',
        'nutrition_guidance'
      ],
    };

    return Column(
      children: categories.entries.map((category) {
        final relevantAnswers = <String, dynamic>{};
        for (final key in category.value) {
          if (answers.containsKey(key)) {
            relevantAnswers[key] = answers[key];
          }
        }

        if (relevantAnswers.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.key,
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 16),
              ...relevantAnswers.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAnswerRow(colors, entry.key, entry.value),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnswerRow(AppColors colors, String key, dynamic value) {
    final label = _getAnswerLabel(key);
    final displayValue = _formatAnswerValue(value);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: colors.text.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            displayValue,
            style: GoogleFonts.assistant(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(
      BuildContext context, AppColors colors, Map<String, dynamic> analysis) {
    final recommendations =
        analysis['training_recommendations'] as List<String>? ?? [];

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.05),
            colors.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'המלצות אימון',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: GoogleFonts.assistant(
                        fontSize: 14,
                        color: colors.text.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTipsSection(
      BuildContext context, AppColors colors, Map<String, String> tips) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'טיפים אישיים',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.entries.map((tip) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTipCategoryName(tip.key),
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.value,
                    style: GoogleFonts.assistant(
                      fontSize: 14,
                      color: colors.text.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, AppColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // כפתור עדכון שאלון
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: Text(
                'עדכן שאלון',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const EnhancedQuestionnaireScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // כפתור לתוכנית אימונים
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.fitness_center),
              label: Text(
                'לתוכנית האימונים',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colors.primary,
                  width: 2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double? _calculateBMI(dynamic height, dynamic weight) {
    if (height == null || weight == null) return null;
    final h = double.tryParse(height.toString());
    final w = double.tryParse(weight.toString());
    if (h == null || w == null) return null;
    return w / ((h / 100) * (h / 100));
  }

  String _extractFrequency(dynamic frequency) {
    if (frequency == null) return '-';
    final match = RegExp(r'\d+').firstMatch(frequency.toString());
    return match?.group(0) ?? '-';
  }

  String _extractDuration(dynamic duration) {
    if (duration == null) return '-';
    final text = duration.toString();
    if (text.contains('30')) return '30';
    if (text.contains('45')) return '45';
    if (text.contains('60')) return '60';
    if (text.contains('שעה')) return '60+';
    return '-';
  }

  String _shortenExperience(dynamic experience) {
    if (experience == null) return '-';
    final text = experience.toString();
    if (text.contains('מתחיל מוחלט')) return 'חדש';
    if (text.contains('מתחיל')) return 'בסיסי';
    if (text.contains('בינוני')) return 'בינוני';
    if (text.contains('מתקדם')) return 'מתקדם';
    if (text.contains('מנוסה')) return 'מקצועי';
    return text.split(' ').first;
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getMotivationColor(String motivation) {
    switch (motivation) {
      case 'גבוהה מאוד':
        return Colors.green;
      case 'גבוהה':
        return Colors.lightGreen;
      case 'בינונית':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getAnswerLabel(String key) {
    final labels = {
      'age': 'גיל',
      'gender': 'מין',
      'height': 'גובה',
      'weight': 'משקל',
      'goal': 'מטרה',
      'goal_timeline': 'קצב התקדמות',
      'frequency': 'תדירות',
      'workout_duration': 'משך אימון',
      'equipment': 'ציוד',
      'experience_level': 'רמת ניסיון',
      'exercise_break': 'התאמנות אחרונה',
      'health_limitations': 'מגבלות בריאותיות',
      'body_focus': 'אזורי מיקוד',
      'workout_style_preference': 'סגנון אימון',
      'avoid_exercises': 'תרגילים להימנע',
      'nutrition_guidance': 'הדרכה תזונתית',
    };
    return labels[key] ?? key;
  }

  String _formatAnswerValue(dynamic value) {
    if (value == null) return '-';
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  String _getTipCategoryName(String category) {
    final names = {
      'nutrition': 'תזונה',
      'recovery': 'התאוששות',
      'technique': 'טכניקה',
      'progression': 'התקדמות',
    };
    return names[category] ?? category;
  }
}
