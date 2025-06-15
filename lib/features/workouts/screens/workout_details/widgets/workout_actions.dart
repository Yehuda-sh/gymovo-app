import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../models/workout_model.dart';
import '../../workout_mode/workout_mode_screen.dart';

class WorkoutActions extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutActions({
    super.key,
    required this.workout,
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
              onPressed: () {
                // TODO: Implement edit functionality
              },
              icon: const Icon(Icons.edit),
              label: Text(
                'ערוך',
                style: GoogleFonts.assistant(),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                      exerciseDetailsMap: const {}, // TODO: Get actual exercise details
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                'התחל אימון',
                style: GoogleFonts.assistant(),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
