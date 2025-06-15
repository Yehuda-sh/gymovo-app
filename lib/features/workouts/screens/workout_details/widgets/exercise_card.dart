import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../models/workout_model.dart';
import 'sets_table.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseCard({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          exercise.name,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
        ),
        subtitle: Text(
          '${exercise.sets.length} סטים',
          style: GoogleFonts.assistant(
            color: colors.headline.withOpacity(0.7),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (exercise.notes != null) ...[
                  Text(
                    exercise.notes!,
                    style: GoogleFonts.assistant(
                      color: colors.headline.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SetsTable(exercise: exercise),
                if (exercise.restTime != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: colors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'זמן מנוחה: ${exercise.restTime} שניות',
                        style: GoogleFonts.assistant(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
