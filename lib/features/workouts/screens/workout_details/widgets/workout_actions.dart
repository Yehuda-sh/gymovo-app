// lib/features/workouts/screens/workout_details/widgets/workout_actions.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../models/workout_model.dart';
import '../../workout_mode/workout_mode_screen.dart';
import '../../new_workout_screen.dart';

class WorkoutActions extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onEdit; // אופציונלי, callback לעריכה

  const WorkoutActions({
    super.key,
    required this.workout,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onEdit ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NewWorkoutScreen(
                          editingWorkout: workout,
                        ),
                      ),
                    );
                  },
              icon: const Icon(Icons.edit),
              label: Text(
                'ערוך',
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: colors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutModeScreen(
                      workout: workout,
                      exerciseDetailsMap: const {}, // TODO: להשלים עם פרטי תרגילים לפני ניווט
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                'התחל אימון',
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
