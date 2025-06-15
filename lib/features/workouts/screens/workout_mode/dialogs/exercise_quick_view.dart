import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../models/exercise.dart';

class ExerciseQuickView extends StatelessWidget {
  final Exercise exercise;

  const ExerciseQuickView({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            exercise.nameHe,
            style: GoogleFonts.assistant(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(exercise.imageUrl!,
                  height: 180, fit: BoxFit.cover),
            ),
          if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('קיים וידאו: ${exercise.videoUrl}',
                  style: GoogleFonts.assistant()),
            ),
          const SizedBox(height: 12),
          if (exercise.instructionsHe.isNotEmpty)
            Text(
              exercise.instructionsHe.join('\n'),
              textAlign: TextAlign.right,
              style: GoogleFonts.assistant(fontSize: 16),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('סגור'),
          ),
        ],
      ),
    );
  }
}
