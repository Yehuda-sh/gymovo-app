// lib/screens/profile/widgets/user_stats_card.dart
// ... (לא שיניתי את ההערות והמבנה הכללי)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';

class UserStatsCard extends StatelessWidget {
  final UserModel user;

  const UserStatsCard({
    super.key,
    required this.user,
  });

  Map<String, dynamic> _calculateStats() {
    final totalWorkouts = user.totalWorkouts ?? 0;

    double totalHours = 0;
    if (user.workoutHistory.isNotEmpty) {
      totalHours = user.workoutHistory.fold<double>(0, (prev, workout) {
        // בדיקה אם יש duration ממשי
        // אם יש שדה duration, עדיף להשתמש בו (למשל: workout.duration ?? 0)
        // כרגע משתמשים בדירוג בלבד
        return prev + (workout.rating ?? 0);
      });
    } else {
      totalHours = totalWorkouts * 0.75;
    }

    final achievements = user.workoutHistory.where((workout) {
      return (workout.rating ?? 0) >= 3;
    }).length;

    return {
      'workouts': totalWorkouts,
      'hours': totalHours.round(),
      'achievements': achievements,
    };
  }

  String _getEncouragementMessage(Map<String, dynamic> stats) {
    final workouts = stats['workouts'] as int;
    final achievements = stats['achievements'] as int;

    if (workouts == 0) {
      return 'מוכן להתחיל את המסע? 🚀';
    } else if (workouts < 5) {
      return 'בתחילת הדרך - כל הכבוד! 💪';
    } else if (workouts < 20) {
      return 'מתקדם יפה! המשך כך! 🎯';
    } else if (achievements > workouts * 0.8) {
      return 'מתאמן מצטיין! 🏆';
    } else {
      return 'מתאמן מנוסה! 🔥';
    }
  }

  Color _getProgressColor(int workouts) {
    if (workouts == 0) return Colors.grey;
    if (workouts < 5) return Colors.blue;
    if (workouts < 20) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final stats = _calculateStats();
    final encouragementMessage = _getEncouragementMessage(stats);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final progressColor = _getProgressColor(stats['workouts'] as int);

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
          // כותרת עם אייקון ובר התקדמות
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: progressColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'הסטטיסטיקות שלי',
                      style: GoogleFonts.assistant(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.headline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      encouragementMessage,
                      style: GoogleFonts.assistant(
                        fontSize: 12,
                        color: colors.text.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // סטטיסטיקות
          isSmallScreen
              ? _buildVerticalStats(stats, colors, progressColor)
              : _buildHorizontalStats(stats, colors, progressColor),

          if (stats['workouts'] > 0) ...[
            const SizedBox(height: 16),
            _buildProgressBar(stats, progressColor),
          ],
        ],
      ),
    );
  }

  Widget _buildHorizontalStats(
      Map<String, dynamic> stats, AppColors colors, Color progressColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'אימונים',
            stats['workouts'].toString(),
            Icons.fitness_center,
            progressColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'שעות',
            stats['hours'].toString(),
            Icons.schedule,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'הישגים',
            stats['achievements'].toString(),
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalStats(
      Map<String, dynamic> stats, AppColors colors, Color progressColor) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'אימונים',
                stats['workouts'].toString(),
                Icons.fitness_center,
                progressColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'שעות',
                stats['hours'].toString(),
                Icons.schedule,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _buildStatCard(
            'הישגים',
            stats['achievements'].toString(),
            Icons.emoji_events,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.text.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> stats, Color progressColor) {
    final workouts = stats['workouts'] as int;
    final achievements = stats['achievements'] as int;
    final progressPercentage = workouts > 0 ? (achievements / workouts) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'רמת הצלחה',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.headline,
              ),
            ),
            Text(
              '${(progressPercentage * 100).toInt()}%',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: progressColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$achievements מתוך $workouts אימונים הושלמו בהצלחה',
          style: GoogleFonts.assistant(
            fontSize: 11,
            color: AppTheme.colors.text.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
