import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/achievement.dart';

class SummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final String period;

  const SummaryCard({
    super.key,
    required this.workouts,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();
    final totalDuration = completedWorkouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['duration'] as int? ?? 0),
    );
    final totalExercises = completedWorkouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['exercises'] as List).length,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'סיכום $period',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.fitness_center,
                    label: 'אימונים',
                    value: completedWorkouts.length.toString(),
                    color: colors.primary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.timer,
                    label: 'דקות',
                    value: totalDuration.toString(),
                    color: colors.secondary,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.repeat,
                    label: 'תרגילים',
                    value: totalExercises.toString(),
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
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
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: color.withOpacity(0.7),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'הישגים',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (achievements.isEmpty)
              Center(
                child: Text(
                  'אין הישגים עדיין',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return ListTile(
                    leading: Icon(
                      achievement.icon,
                      color: colors.primary,
                    ),
                    title: Text(
                      achievement.title,
                      style: GoogleFonts.assistant(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      achievement.description,
                      style: GoogleFonts.assistant(
                        fontSize: 12,
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
