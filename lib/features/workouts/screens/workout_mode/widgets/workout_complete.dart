// lib/features/workouts/screens/workout_mode/widgets/workout_complete.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';

class WorkoutCompleteWidget extends StatelessWidget {
  const WorkoutCompleteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'כל הכבוד!',
              style: GoogleFonts.assistant(
                color: Colors.green[700],
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'סיימת את כל האימון בהצלחה',
              style: GoogleFonts.assistant(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false),
              label: const Text('חזרה לדף הבית'),
            ),
          ],
        ),
      ),
    );
  }
}
