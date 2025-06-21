// lib/features/exercises/widgets/exercise_media_section.dart
import 'package:flutter/material.dart';
import '../../../models/exercise.dart';

class ExerciseMediaSection extends StatefulWidget {
  final Exercise exercise;

  const ExerciseMediaSection({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseMediaSection> createState() => _ExerciseMediaSectionState();
}

class _ExerciseMediaSectionState extends State<ExerciseMediaSection> {
  bool _isImageLoading = true;

  @override
  Widget build(BuildContext context) {
    // וידאו קודם לתמונה (אם תטמיע בעתיד נגן)
    if (widget.exercise.videoUrl?.isNotEmpty == true) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 50),
              Text('וידאו זמין'),
            ],
          ),
        ),
      );
    }

    if (widget.exercise.displayImage?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Image.network(
              widget.exercise.displayImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  if (_isImageLoading) {
                    setState(() => _isImageLoading = false);
                  }
                  return child;
                } else {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported),
                  ),
                );
              },
            ),
            // Overlay semanitcs for accessibility
            Semantics(
              label: 'תמונה של תרגיל: ${widget.exercise.name}',
            ),
          ],
        ),
      );
    }

    // אם אין כלום
    return const SizedBox.shrink();
  }
}
