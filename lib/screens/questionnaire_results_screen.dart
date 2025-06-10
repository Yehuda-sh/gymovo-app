// lib/screens/questionnaire_results_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/local_data_store.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../screens/questionnaire_screen.dart';

class QuestionnaireResultsScreen extends StatelessWidget {
  const QuestionnaireResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('תוצאות השאלון'),
        backgroundColor: colors.surface,
      ),
      body: FutureBuilder<UserModel?>(
        future: LocalDataStore.getCurrentUser(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null || user.preferences == null) {
            return const Center(child: Text('אין נתונים להצגה'));
          }

          final prefs = user.preferences!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSection(
                  'פרופיל אישי',
                  [
                    _buildInfoRow('שם', user.name ?? 'לא הוזן'),
                    _buildInfoRow('גיל', user.age?.toString() ?? 'לא הוזן'),
                  ],
                  colors,
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'העדפות אימון',
                  [
                    _buildInfoRow('רמת כושר',
                        prefs.experienceLevel?.displayName ?? 'לא הוזן'),
                    _buildInfoRow('מטרה', prefs.goal?.displayName ?? 'לא הוזן'),
                    _buildInfoRow(
                        'ציוד זמין', prefs.equipment?.join(', ') ?? 'לא הוזן'),
                    _buildInfoRow('תדירות בשבוע',
                        prefs.frequency?.displayName ?? 'לא הוזן'),
                    _buildInfoRow('זמן מועדף', prefs.workoutTime ?? 'לא הוזן'),
                    _buildInfoRow(
                        'משך אימון', prefs.workoutDuration ?? 'לא הוזן'),
                  ],
                  colors,
                ),
                const SizedBox(height: 24),
                _buildDecisionTree(prefs, colors),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'עדכון השאלון',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionTree(UserPreferences prefs, AppColors colors) {
    final Map<String, String?> mapping = {
      'רמת כושר': prefs.experienceLevel?.displayName,
      'מטרה': prefs.goal?.displayName,
      'ציוד זמין': prefs.equipment?.join(', '),
      'תדירות בשבוע': prefs.frequency?.displayName,
    };

    return _buildSection(
      'התאמה כללית',
      mapping.entries.map((e) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.key,
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.headline,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                e.value ?? 'לא הוזן',
                textAlign: TextAlign.center,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: colors.headline,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
      colors,
    );
  }
}
