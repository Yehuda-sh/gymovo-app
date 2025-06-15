// lib/screens/questionnaire_results_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/local_data_store.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../questionnaire/questionnaire_screen.dart';

class QuestionnaireResultsScreen extends StatelessWidget {
  const QuestionnaireResultsScreen({super.key});

  Future<void> _checkSharedPreferencesDirectly() async {
    debugPrint('=== DIRECT SharedPreferences CHECK ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserString = prefs.getString('current_user');
      debugPrint(
          'Raw current_user string exists: ${currentUserString != null}');
      debugPrint(
          'Raw current_user string length: ${currentUserString?.length}');

      if (currentUserString != null) {
        final userData = json.decode(currentUserString);
        debugPrint(
            'Direct check - parsed user keys: ${userData.keys.toList()}');
        debugPrint(
            'Direct check - questionnaire_answers: ${userData['questionnaire_answers']}');
        debugPrint(
            'Direct check - questionnaire_answers type: ${userData['questionnaire_answers'].runtimeType}');

        if (userData['questionnaire_answers'] != null) {
          final qa = userData['questionnaire_answers'];
          if (qa is Map) {
            debugPrint(
                'Direct check - questionnaire_answers keys: ${qa.keys.toList()}');
            debugPrint('Direct check - sample values:');
            for (final key in [
              'age',
              'height',
              'weight',
              'goal',
              'frequency'
            ]) {
              if (qa.containsKey(key)) {
                debugPrint('  $key: ${qa[key]} (${qa[key].runtimeType})');
              } else {
                debugPrint('  $key: NOT FOUND');
              }
            }
          } else {
            debugPrint('Direct check - questionnaire_answers is not a Map!');
          }
        } else {
          debugPrint('Direct check - questionnaire_answers is null');
        }
      } else {
        debugPrint('Direct check - no current_user found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Error in direct SharedPreferences check: $e');
    }
    debugPrint('=======================================');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'תוצאות השאלון שלך',
          style: GoogleFonts.assistant(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: FutureBuilder<UserModel?>(
        future: LocalDataStore.getCurrentUser(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          // הוסף בדיקה ישירה של SharedPreferences
          _checkSharedPreferencesDirectly();

          final user = snapshot.data;

          // הדפסות debug מקיפות
          debugPrint('=== DEBUG: QuestionnaireResultsScreen ===');
          debugPrint('user: ${user != null ? 'exists' : 'null'}');
          debugPrint('user.id: ${user?.id}');
          debugPrint('user.isGuest: ${user?.isGuest}');
          debugPrint(
              'user.questionnaireAnswers is null: ${user?.questionnaireAnswers == null}');
          debugPrint(
              'user.questionnaireAnswers isEmpty: ${user?.questionnaireAnswers?.isEmpty}');
          debugPrint(
              'user.questionnaireAnswers keys: ${user?.questionnaireAnswers?.keys.toList()}');
          debugPrint(
              'user.questionnaireAnswers full content: ${user?.questionnaireAnswers}');

          // הדפסת ערכים ספציפיים
          if (user?.questionnaireAnswers != null) {
            final qa = user!.questionnaireAnswers!;
            debugPrint('age: ${qa['age']} (type: ${qa['age'].runtimeType})');
            debugPrint(
                'height: ${qa['height']} (type: ${qa['height'].runtimeType})');
            debugPrint(
                'weight: ${qa['weight']} (type: ${qa['weight'].runtimeType})');
            debugPrint('goal: ${qa['goal']} (type: ${qa['goal'].runtimeType})');
            debugPrint(
                'frequency: ${qa['frequency']} (type: ${qa['frequency'].runtimeType})');
          }
          debugPrint('==========================================');

          final hasAnswers = user?.questionnaireAnswers != null &&
              (user!.questionnaireAnswers?.isNotEmpty ?? false);

          debugPrint('hasAnswers final result: $hasAnswers');

          if (user == null || !hasAnswers) {
            debugPrint('Showing "no questionnaire data" message');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: colors.text.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'לא נמצאו נתוני שאלון',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      color: colors.text.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // הוסף מידע debug גם בממשק המשתמש
                  if (user != null)
                    Text(
                      'Debug: questionnaireAnswers is ${user.questionnaireAnswers == null ? 'null' : 'not null but ${user.questionnaireAnswers?.length ?? 0} items'}',
                      style: GoogleFonts.assistant(
                        fontSize: 12,
                        color: colors.text.withValues(alpha: 0.4),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      'מלא שאלון',
                      style: GoogleFonts.assistant(fontSize: 16),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // תיקון: טיפול בטוח ב-preferences
          final prefs = user.preferences; // הסרת ה-!
          // Get questionnaire answers from user model
          final questAnswers = user.questionnaireAnswers ?? {};

          debugPrint('questAnswers after assignment: $questAnswers');
          debugPrint('questAnswers keys count: ${questAnswers.keys.length}');

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section with Profile Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.1),
                        colors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colors.primary,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name.substring(0, 1).toUpperCase()
                              : '?',
                          style: GoogleFonts.assistant(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name ?? 'משתמש אורח',
                        style: GoogleFonts.assistant(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.headline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildQuickStats(questAnswers, colors),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // פרטים אישיים
                      _buildDetailedSection(
                        title: 'פרטים אישיים',
                        icon: Icons.person_outline,
                        items: [
                          _DetailItem(
                            'גיל',
                            questAnswers['age'] != null
                                ? '${questAnswers['age']} שנים'
                                : user.age != null
                                    ? '${user.age} שנים'
                                    : '-',
                            Icons.cake_outlined,
                          ),
                          _DetailItem(
                            'גובה',
                            questAnswers['height'] != null
                                ? '${questAnswers['height']} ס"מ'
                                : '-',
                            Icons.height,
                          ),
                          _DetailItem(
                            'משקל',
                            questAnswers['weight'] != null
                                ? '${questAnswers['weight']} ק"ג'
                                : '-',
                            Icons.monitor_weight_outlined,
                          ),
                          if (questAnswers['height'] != null &&
                              questAnswers['weight'] != null)
                            _DetailItem(
                              'BMI',
                              _calculateBMI(
                                questAnswers['height'],
                                questAnswers['weight'],
                              ),
                              Icons.analytics_outlined,
                            ),
                        ],
                        colors: colors,
                      ),

                      const SizedBox(height: 20),

                      // מטרות ויעדים
                      _buildDetailedSection(
                        title: 'מטרות ויעדים',
                        icon: Icons.flag_outlined,
                        items: [
                          _DetailItem(
                            'מטרה ראשית',
                            questAnswers['goal'] ??
                                prefs?.goal?.displayName ??
                                '-',
                            Icons.flag_circle_outlined,
                          ),
                          _DetailItem(
                            'קצב התקדמות',
                            questAnswers['goal_timeline'] ?? '-',
                            Icons.speed,
                          ),
                          _DetailItem(
                            'אזורי מיקוד',
                            _formatMultiAnswer(questAnswers['body_focus']),
                            Icons.fitness_center,
                          ),
                        ],
                        colors: colors,
                      ),

                      const SizedBox(height: 20),

                      // ניסיון וזמינות
                      _buildDetailedSection(
                        title: 'ניסיון וזמינות',
                        icon: Icons.schedule,
                        items: [
                          _DetailItem(
                            'רמת ניסיון',
                            questAnswers['experience_level'] ??
                                prefs?.experienceLevel?.displayName ??
                                '-',
                            Icons.bar_chart,
                          ),
                          _DetailItem(
                            'התאמנות אחרונה',
                            questAnswers['exercise_break'] ?? '-',
                            Icons.history,
                          ),
                          _DetailItem(
                            'תדירות שבועית',
                            questAnswers['frequency'] ?? '-',
                            Icons.calendar_today,
                          ),
                          _DetailItem(
                            'משך אימון',
                            questAnswers['workout_duration']?.toString() ??
                                prefs?.workoutDuration?.toString() ??
                                '-',
                            Icons.timer,
                          ),
                        ],
                        colors: colors,
                      ),

                      const SizedBox(height: 20),

                      // ציוד וסביבת אימון
                      _buildDetailedSection(
                        title: 'ציוד וסביבת אימון',
                        icon: Icons.sports_gymnastics,
                        items: [
                          _DetailItem(
                            'מיקום אימון',
                            questAnswers['equipment'] ?? '-',
                            Icons.home_work_outlined,
                          ),
                          if (questAnswers['home_equipment'] != null)
                            _DetailItem(
                              'ציוד זמין',
                              _formatMultiAnswer(
                                  questAnswers['home_equipment']),
                              Icons.sports,
                            ),
                        ],
                        colors: colors,
                      ),

                      const SizedBox(height: 20),

                      // בריאות ומגבלות
                      if (questAnswers['health_limitations'] != null ||
                          questAnswers['avoid_exercises'] != null)
                        _buildDetailedSection(
                          title: 'בריאות ומגבלות',
                          icon: Icons.health_and_safety_outlined,
                          items: [
                            if (questAnswers['health_limitations'] != null)
                              _DetailItem(
                                'מגבלות בריאותיות',
                                _formatMultiAnswer(
                                    questAnswers['health_limitations']),
                                Icons.medical_information_outlined,
                              ),
                            if (questAnswers['avoid_exercises'] != null)
                              _DetailItem(
                                'תרגילים להימנע',
                                _formatMultiAnswer(
                                    questAnswers['avoid_exercises']),
                                Icons.do_not_disturb_on_outlined,
                              ),
                          ],
                          colors: colors,
                        ),

                      const SizedBox(height: 20),

                      // העדפות נוספות
                      _buildDetailedSection(
                        title: 'העדפות נוספות',
                        icon: Icons.tune,
                        items: [
                          _DetailItem(
                            'סגנון אימון',
                            _formatMultiAnswer(
                                questAnswers['workout_style_preference']),
                            Icons.sports_martial_arts,
                          ),
                          if (questAnswers['nutrition_guidance'] != null)
                            _DetailItem(
                              'הדרכה תזונתית',
                              questAnswers['nutrition_guidance'] ?? '-',
                              Icons.restaurant_menu,
                            ),
                        ],
                        colors: colors,
                      ),

                      const SizedBox(height: 40),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const QuestionnaireScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: colors.primary,
                                  width: 2,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/home');
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> answers, AppColors colors) {
    debugPrint('_buildQuickStats called with answers: $answers');

    final stats = [
      {
        'label': 'ימי אימון',
        'value': _extractNumber(answers['frequency']) ?? '-',
      },
      {
        'label': 'דקות לאימון',
        'value': _extractNumber(answers['workout_duration']) ?? '-',
      },
      {
        'label': 'רמת ניסיון',
        'value': _shortenExperienceLevel(answers['experience_level']),
      },
    ];

    debugPrint('Quick stats computed: $stats');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) {
        return Column(
          children: [
            Text(
              stat['value']!,
              style: GoogleFonts.assistant(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            Text(
              stat['label']!,
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

  Widget _buildDetailedSection({
    required String title,
    required IconData icon,
    required List<_DetailItem> items,
    required AppColors colors,
  }) {
    debugPrint('_buildDetailedSection called for: $title');
    debugPrint(
        'Items: ${items.map((item) => '${item.label}: ${item.value}').toList()}');

    // Filter out items with empty values
    final validItems = items.where((item) => item.value != '-').toList();
    debugPrint(
        'Valid items after filtering: ${validItems.map((item) => '${item.label}: ${item.value}').toList()}');

    if (validItems.isEmpty) {
      debugPrint('No valid items for section $title, returning empty widget');
      return const SizedBox.shrink();
    }

    return Container(
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...validItems
              .map((item) => _buildDetailRow(item, colors))
              .expand((widget) => [widget, const SizedBox(height: 16)]),
        ],
      ),
    );
  }

  Widget _buildDetailRow(_DetailItem item, AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.icon,
          size: 20,
          color: colors.text.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: colors.text.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMultiAnswer(dynamic answer) {
    debugPrint(
        '_formatMultiAnswer called with: $answer (type: ${answer.runtimeType})');

    if (answer == null) {
      debugPrint('_formatMultiAnswer: answer is null, returning "-"');
      return '-';
    }
    if (answer is List) {
      if (answer.isEmpty) {
        debugPrint('_formatMultiAnswer: answer is empty list, returning "-"');
        return '-';
      }
      final result = answer.join(' • ');
      debugPrint('_formatMultiAnswer: list result: $result');
      return result;
    }
    final result = answer.toString();
    debugPrint('_formatMultiAnswer: string result: $result');
    return result;
  }

  String _calculateBMI(dynamic height, dynamic weight) {
    debugPrint(
        '_calculateBMI called with height: $height (${height.runtimeType}), weight: $weight (${weight.runtimeType})');
    try {
      final h = double.parse(height.toString()) / 100; // Convert cm to m
      final w = double.parse(weight.toString());
      final bmi = w / (h * h);
      debugPrint('BMI calculated: $bmi');

      String category;
      if (bmi < 18.5) {
        category = 'תת משקל';
      } else if (bmi < 25) {
        category = 'משקל תקין';
      } else if (bmi < 30) {
        category = 'עודף משקל';
      } else {
        category = 'השמנה';
      }

      final result = '${bmi.toStringAsFixed(1)} ($category)';
      debugPrint('BMI result: $result');
      return result;
    } catch (e) {
      debugPrint('Error calculating BMI: $e');
      return '-';
    }
  }

  String? _extractNumber(dynamic value) {
    debugPrint(
        '_extractNumber called with: $value (type: ${value.runtimeType})');
    if (value == null) {
      debugPrint('_extractNumber: value is null, returning null');
      return null;
    }
    final text = value.toString();
    final match = RegExp(r'\d+').firstMatch(text);
    final result = match?.group(0);
    debugPrint('_extractNumber result: $result');
    return result;
  }

  String _shortenExperienceLevel(dynamic level) {
    debugPrint(
        '_shortenExperienceLevel called with: $level (type: ${level.runtimeType})');
    if (level == null) {
      debugPrint('_shortenExperienceLevel: level is null, returning "-"');
      return '-';
    }

    final levelString = level.toString();
    final mapping = {
      'מתחיל מוחלט': 'מתחיל',
      'מתחיל עם ניסיון בסיסי': 'בסיסי',
      'מתאמן בינוני': 'בינוני',
      'מתקדם': 'מתקדם',
      'מנוסה מאוד': 'מנוסה',
    };

    final result = mapping[levelString] ?? levelString.split(' ').first;
    debugPrint('_shortenExperienceLevel result: $result');
    return result;
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  _DetailItem(this.label, this.value, this.icon);
}
