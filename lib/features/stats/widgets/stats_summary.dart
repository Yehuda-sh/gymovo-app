// lib/features/stats/widgets/stats_summary.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';

// Enum לנדירות הישגים (אם לא קיים)
enum AchievementRarity { common, rare, epic, legendary }

// מחלקה לניהול הישגים (אם לא קיימת)
class AchievementService {
  static List<Achievement> getAchievements(
      List<Map<String, dynamic>> workouts) {
    List<Achievement> achievements = [];

    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();

    // הישג ראשון
    if (completedWorkouts.isNotEmpty) {
      achievements.add(Achievement(
        title: "אימון ראשון",
        description: "יצאת לדרך - ביצעת את האימון הראשון שלך!",
        icon: Icons.emoji_events,
        unlockedAt: DateTime.parse(completedWorkouts.first['completed_at']),
        rarity: AchievementRarity.common,
      ));
    }

    // הישג 5 אימונים
    if (completedWorkouts.length >= 5) {
      achievements.add(Achievement(
        title: "5 אימונים",
        description: "השלמת 5 אימונים - נתחיל ברצינות!",
        icon: Icons.fitness_center,
        rarity: AchievementRarity.common,
        tip: "המשך כך ותגיע ליעדים!",
      ));
    }

    // הישג שבועי
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final thisWeekWorkouts = completedWorkouts
        .where((w) => DateTime.parse(w['completed_at']).isAfter(lastWeek))
        .length;

    if (thisWeekWorkouts >= 3) {
      achievements.add(Achievement(
        title: "ספורטאי השבוע",
        description: "השלמת 3 אימונים או יותר השבוע!",
        icon: Icons.star,
        rarity: AchievementRarity.rare,
        tip: "עקוב אחר התקדמותך בלוח השנה!",
      ));
    }

    return achievements;
  }
}

// מחלקת Achievement (אם לא קיימת)
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final DateTime? unlockedAt;
  final AchievementRarity rarity;
  final String? tip;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.rarity,
    this.tip,
  });
}

class SummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final String period;

  const SummaryCard({
    super.key,
    required this.workouts,
    required this.period,
  });

  // פונקציה לחישוב סטטיסטיקות
  Map<String, int> _calculateStats() {
    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();

    final totalDuration = completedWorkouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['duration'] as int? ?? 0),
    );

    final totalExercises = completedWorkouts.fold<int>(
      0,
      (sum, workout) => sum + ((workout['exercises'] as List?)?.length ?? 0),
    );

    // חישוב ממוצע משך אימון
    final avgDuration = completedWorkouts.isEmpty
        ? 0
        : (totalDuration / completedWorkouts.length).round();

    return {
      'completedWorkouts': completedWorkouts.length,
      'totalDuration': totalDuration,
      'totalExercises': totalExercises,
      'avgDuration': avgDuration,
    };
  }

  // פורמט זמן יותר נוח (דקות לשעות:דקות)
  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}ד';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}ש ${remainingMinutes}ד';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final stats = _calculateStats();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'סיכום $period',
                  style: GoogleFonts.assistant(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // שורה ראשונה - אימונים וזמן כולל
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.fitness_center,
                    label: 'אימונים',
                    value: stats['completedWorkouts'].toString(),
                    color: colors.primary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.timer_outlined,
                    label: 'זמן כולל',
                    value: _formatDuration(stats['totalDuration']!),
                    color: colors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // שורה שנייה - תרגילים וממוצע
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.repeat_rounded,
                    label: 'תרגילים',
                    value: stats['totalExercises'].toString(),
                    color: colors.tertiary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.trending_up,
                    label: 'ממוצע/אימון',
                    value: _formatDuration(stats['avgDuration']!),
                    color: colors.outline,
                  ),
                ),
              ],
            ),

            // אינדיקטור התקדמות (אם יש יעד)
            if (stats['completedWorkouts']! > 0) ...[
              const SizedBox(height: 16),
              _ProgressIndicator(
                completedWorkouts: stats['completedWorkouts']!,
                period: period,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 13,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ווידג'ט חדש לאינדיקטור התקדמות
class _ProgressIndicator extends StatelessWidget {
  final int completedWorkouts;
  final String period;

  const _ProgressIndicator({
    required this.completedWorkouts,
    required this.period,
  });

  // יעדים לפי תקופה
  int _getTargetForPeriod() {
    switch (period.toLowerCase()) {
      case 'שבוע':
      case 'השבוע':
        return 3; // 3 אימונים בשבוע
      case 'חודש':
      case 'החודש':
        return 12; // 12 אימונים בחודש
      default:
        return completedWorkouts; // אין יעד מוגדר
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final target = _getTargetForPeriod();
    final progress = (completedWorkouts / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'התקדמות ליעד',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              '$completedWorkouts/$target',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colors.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? Colors.green : colors.primary,
          ),
        ),
      ],
    );
  }
}

class AchievementsCard extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;

  const AchievementsCard({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final achievements = AchievementService.getAchievements(workouts);
    // מיון הישגים לפי תאריך (החדשים ראשונים)
    achievements.sort((a, b) => (b.unlockedAt ?? DateTime(2000))
        .compareTo(a.unlockedAt ?? DateTime(2000)));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'הישגים',
                      style: GoogleFonts.assistant(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                if (achievements.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${achievements.length}',
                      style: GoogleFonts.assistant(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (achievements.isEmpty)
              _EmptyStateWidget(colors: colors)
            else
              // הצגת עד 3 הישגים אחרונים
              Column(
                children: achievements.take(3).map((achievement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementItem(
                      achievement: achievement,
                      colors: colors,
                    ),
                  );
                }).toList(),
              ),

            // כפתור לצפייה בכל ההישגים
            if (achievements.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // ניווט לעמוד הישגים מלא
                    Navigator.pushNamed(context, '/achievements');
                  },
                  icon: Icon(Icons.arrow_forward, size: 16),
                  label: Text(
                    'צפה בכל ההישגים (${achievements.length})',
                    style: GoogleFonts.assistant(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final ColorScheme colors;

  const _EmptyStateWidget({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: colors.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'אין הישגים עדיין',
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'התחל להתאמן כדי לפתוח הישגים!',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: colors.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final Achievement achievement;
  final ColorScheme colors;

  const _AchievementItem({
    required this.achievement,
    required this.colors,
  });

  // צבע לפי נדירות ההישג
  Color _getRarityColor() {
    switch (achievement.rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
      default:
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: rarityColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: rarityColor.withOpacity(0.05),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: rarityColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.icon,
            color: rarityColor,
            size: 24,
          ),
        ),
        title: Text(
          achievement.title,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: GoogleFonts.assistant(
                fontSize: 13,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            if (achievement.unlockedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'נפתח ב-${_formatDate(achievement.unlockedAt!)}',
                style: GoogleFonts.assistant(
                  fontSize: 11,
                  color: rarityColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: achievement.tip != null
            ? IconButton(
                icon: Icon(Icons.lightbulb_outline,
                    color: colors.primary, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(achievement.tip!),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'היום';
    if (difference == 1) return 'אתמול';
    if (difference < 7) return 'לפני $difference ימים';
    if (difference < 30) return 'לפני ${(difference / 7).round()} שבועות';
    return 'לפני ${(difference / 30).round()} חודשים';
  }
}
