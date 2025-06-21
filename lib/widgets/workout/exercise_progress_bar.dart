// lib/widgets/workout/exercise_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ExerciseProgressBar extends StatelessWidget {
  final int currentExerciseIndex;
  final int currentSet;
  final int totalExercises;
  final int totalSets;
  final Duration elapsedTime;

  const ExerciseProgressBar({
    super.key,
    required this.currentExerciseIndex,
    required this.currentSet,
    required this.totalExercises,
    required this.totalSets,
    required this.elapsedTime,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final totalSteps = (totalExercises * totalSets).clamp(1, double.infinity);
    final currentStep =
        (currentExerciseIndex * totalSets + currentSet).clamp(0, totalSteps);
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    return Semantics(
      label: 'התקדמות אימון',
      value:
          'סט ${currentSet + 1} מתוך $totalSets, תרגיל ${currentExerciseIndex + 1} מתוך $totalExercises, זמן חולף ${_formatDuration(elapsedTime)}',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.96),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(14),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // פס התקדמות עם אנימציה חלקה
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: colors.primary.withOpacity(0.13),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      value == 1.0 ? Colors.green : colors.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: colors.accent,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(elapsedTime),
                  style: GoogleFonts.assistant(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'סט ${currentSet + 1}/$totalSets | תרגיל ${currentExerciseIndex + 1}/$totalExercises',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.headline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (progress == 1.0) ...[
                  const SizedBox(width: 10),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  Text('הושלם!',
                      style: GoogleFonts.assistant(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      )),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
