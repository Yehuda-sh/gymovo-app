// lib/screens/profile/widgets/quick_actions_card.dart
// --------------------------------------------------
// כרטיס פעולות מהירות בפרופיל
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

/// כרטיס פעולות מהירות בפרופיל
///
/// תכונות:
/// - שאלון מחדש
/// - שיתוף אפליקציה
/// - עיצוב אחיד עם אנימציות
/// - נגישות מלאה
class QuickActionsCard extends StatelessWidget {
  /// פונקציה לשאלון מחדש
  final VoidCallback onQuestionnaireRestart;

  /// פונקציה לשיתוף אפליקציה
  final VoidCallback onShareApp;

  const QuickActionsCard({
    super.key,
    required this.onQuestionnaireRestart,
    required this.onShareApp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // כותרת הסקציה
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flash_on,
                  color: colors.secondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'פעולות מהירות',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // כפתורי פעולה
          isSmallScreen
              ? _buildVerticalActions(colors)
              : _buildHorizontalActions(colors),
        ],
      ),
    );
  }

  /// בונה פעולות אופקיות (מסכים רגילים)
  Widget _buildHorizontalActions(AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            label: 'שאלון מחדש',
            description: 'מלא שוב את שאלון ההתאמה',
            icon: Icons.assignment_outlined,
            color: colors.primary,
            onTap: onQuestionnaireRestart,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            label: 'שתף אפליקציה',
            description: 'שתף עם חברים ומשפחה',
            icon: Icons.share_outlined,
            color: colors.secondary,
            onTap: onShareApp,
          ),
        ),
      ],
    );
  }

  /// בונה פעולות אנכיות (מסכים קטנים)
  Widget _buildVerticalActions(AppColors colors) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: _buildQuickActionButton(
            label: 'שאלון מחדש',
            description: 'מלא שוב את שאלון ההתאמה',
            icon: Icons.assignment_outlined,
            color: colors.primary,
            onTap: onQuestionnaireRestart,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildQuickActionButton(
            label: 'שתף אפליקציה',
            description: 'שתף עם חברים ומשפחה',
            icon: Icons.share_outlined,
            color: colors.secondary,
            onTap: onShareApp,
          ),
        ),
      ],
    );
  }

  /// בונה כפתור פעולה מהירה
  Widget _buildQuickActionButton({
    required String label,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$label: $description',
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.assistant(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            style: GoogleFonts.assistant(
                              fontSize: 12,
                              color: AppTheme.colors.text.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_left,
                      color: color.withOpacity(0.7),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
