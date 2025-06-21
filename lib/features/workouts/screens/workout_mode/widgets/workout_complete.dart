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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'אייקון סיום אימון',
            child: Icon(Icons.emoji_events, color: colors.success, size: 80),
          ),
          const SizedBox(height: 20),
          Text(
            'כל הכבוד!',
            style: GoogleFonts.assistant(
              color: colors.success,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'סיימת את כל האימון בהצלחה',
            style: GoogleFonts.assistant(
              color: colors.text.withOpacity(0.7),
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            icon: const Icon(Icons.home),
            label: Text(
              'חזרה לדף הבית',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: const Size(160, 48),
            ),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false),
          ),
        ],
      ),
    );
  }
}
