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
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final isComplete = completed == total && total != 0;

    // צבע אינדיקציה: ירוק אם סיים, אחרת צבע ראשי או כתום אם קרוב לסיום
    final progressColor = isComplete
        ? Colors.green
        : (progress > 0.7 ? Colors.orange : colors.primary);

    // טקסט אינדיקציה לצד המספרים
    final progressPercent = (progress * 100).toInt();

    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: '$progressPercent% הושלם',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$completed/$total',
          style: GoogleFonts.assistant(
            color: progressColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
