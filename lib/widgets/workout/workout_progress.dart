// lib/widgets/workout_progress.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class WorkoutProgress extends StatelessWidget {
  final int currentExerciseIndex;
  final int totalExercises;
  final int currentSet;
  final int totalSets;

  const WorkoutProgress({
    super.key,
    required this.currentExerciseIndex,
    required this.totalExercises,
    required this.currentSet,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.primary.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'התקדמות האימון',
            style: GoogleFonts.assistant(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressSection(
                  label: 'תרגילים',
                  current: currentExerciseIndex + 1,
                  total: totalExercises,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressSection(
                  label: 'סטים',
                  current: currentSet,
                  total: totalSets,
                  color: colors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required String label,
    required int current,
    required int total,
    required Color color,
  }) {
    final safeTotal = total == 0 ? 1 : total;
    final progress = current / safeTotal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.colors.background.withAlpha(60),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$current/$total',
          style: GoogleFonts.assistant(
            fontSize: 13,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}
