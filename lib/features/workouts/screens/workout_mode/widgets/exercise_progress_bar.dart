// lib/features/workouts/screens/workout_mode/widgets/exercise_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';

class ExerciseProgressBar extends StatelessWidget {
  final int total;
  final int completed;

  const ExerciseProgressBar({
    super.key,
    required this.total,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                  completed == total ? Colors.green : colors.primary),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$completed/$total',
          style: GoogleFonts.assistant(
              color: completed == total ? Colors.green : colors.primary,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
