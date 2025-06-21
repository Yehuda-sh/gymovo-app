// lib/features/workouts/screens/workout_mode/dialogs/exercise_quick_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../models/exercise.dart';

class ExerciseQuickView extends StatelessWidget {
  final Exercise exercise;

  const ExerciseQuickView({
    super.key,
    required this.exercise,
  });

  Future<void> _launchVideoUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasVideo = exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty;
    final hasImage =
        exercise.displayImage != null && exercise.displayImage!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              exercise.nameHe,
              textAlign: TextAlign.right,
              style: GoogleFonts.assistant(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  exercise.displayImage!,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: colors.onSurface.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'אין תמונה זמינה',
                  style: GoogleFonts.assistant(
                    color: colors.onSurface.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (hasVideo)
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: Text(
                  'צפה בווידאו',
                  style: GoogleFonts.assistant(),
                ),
                onPressed: () => _launchVideoUrl(exercise.videoUrl!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )
            else
              Text(
                'אין וידאו זמין',
                textAlign: TextAlign.center,
                style: GoogleFonts.assistant(
                  color: colors.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            if (hasVideo) const SizedBox(height: 16),
            if (exercise.instructionsHe.isNotEmpty)
              Text(
                exercise.instructionsHe.join('\n\n'),
                textAlign: TextAlign.right,
                style: GoogleFonts.assistant(fontSize: 16, height: 1.4),
              )
            else
              Text(
                'אין הוראות זמינות',
                textAlign: TextAlign.center,
                style: GoogleFonts.assistant(
                  color: colors.onSurface.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: Text(
                'סגור',
                style: GoogleFonts.assistant(),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: colors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
