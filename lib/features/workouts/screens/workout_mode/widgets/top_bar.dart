// lib/features/workouts/screens/workout_mode/widgets/top_bar.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../theme/app_theme.dart';
import '../../../providers/workout_mode_provider.dart';

class WorkoutTopBar extends StatelessWidget {
  final VoidCallback onFinishWorkout;

  const WorkoutTopBar({super.key, required this.onFinishWorkout});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkoutModeProvider>(context);
    final colors = AppTheme.colors;

    return Container(
      margin: const EdgeInsets.only(top: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.90),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // חזור למסך הבית
          IconButton(
            icon: Icon(Icons.arrow_back, color: colors.primary),
            tooltip: 'חזור',
            onPressed: () => Navigator.of(context).pop(),
          ),
          // סטופר זמן אימון
          Row(
            children: [
              Icon(Icons.timer, size: 19, color: colors.accent),
              const SizedBox(width: 3),
              Text(
                provider.formattedElapsed,
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${provider.progressPercent}%",
                style: GoogleFonts.assistant(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          // כפתורי השהייה/המשך וסיים
          Row(
            children: [
              IconButton(
                icon: Icon(
                  provider.isPaused ? Icons.play_arrow : Icons.pause,
                  color: colors.primary,
                ),
                tooltip: provider.isPaused ? 'המשך' : 'השהה',
                onPressed: provider.togglePause,
              ),
              const SizedBox(width: 2),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                ),
                onPressed: onFinishWorkout,
                child: Text('סיים אימון',
                    style: GoogleFonts.assistant(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          // משקל מצטבר
          Row(
            children: [
              Icon(Icons.fitness_center, size: 19, color: colors.primary),
              const SizedBox(width: 3),
              Text(
                "${provider.totalWeight} ק\"ג",
                style: GoogleFonts.assistant(
                  color: colors.headline,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
