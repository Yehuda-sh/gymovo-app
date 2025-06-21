// lib/features/workouts/screens/workout_details/widgets/workout_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../models/workout_model.dart';
import 'workout_info_chip.dart';

class WorkoutHeader extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutHeader({
    super.key,
    required this.workout,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.title,
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          if (workout.description != null &&
              workout.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              workout.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: colors.headline.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Tooltip(
                message: 'מספר התרגילים באימון',
                child: WorkoutInfoChip(
                  icon: Icons.fitness_center,
                  label: '${workout.exercises.length} תרגילים',
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: 'תאריך יצירת האימון',
                child: WorkoutInfoChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(workout.createdAt),
                  color: colors.accent,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
