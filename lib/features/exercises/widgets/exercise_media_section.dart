import 'package:flutter/material.dart';
import '../../../models/exercise.dart';

class ExerciseMediaSection extends StatefulWidget {
  final Exercise exercise;

  const ExerciseMediaSection({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseMediaSection> createState() => _ExerciseMediaSectionState();
}

class _ExerciseMediaSectionState extends State<ExerciseMediaSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.exercise.imageUrl?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.exercise.imageUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
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
      );
    }

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

    return const SizedBox.shrink();
  }
}
