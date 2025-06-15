// lib/widgets/exercise_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muscles = primaryMuscles;
    final secondary = secondaryMuscles;
    final equipment = exercise.equipment?.isNotEmpty == true
        ? exercise.equipment!
        : 'לא צוין';
    final instructionsPreview = exercise.instructionsHe.isNotEmpty
        ? exercise.instructionsHe.join('\n')
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: CachedNetworkImage(
                  imageUrl: exercise.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.nameHe,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.fitness_center,
                          size: 18, color: Colors.blueGrey[400]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'קבוצת שרירים: $muscles',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (secondary != null && secondary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.double_arrow,
                            size: 16, color: Colors.teal[400]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'שרירים משניים: $secondary',
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.handyman, size: 16, color: Colors.amber[700]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ציוד: $equipment',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    instructionsPreview,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get primaryMuscles {
    final mainMuscles = exercise.mainMuscles;
    if (mainMuscles != null && mainMuscles.isNotEmpty) {
      return mainMuscles.join(', ');
    }
    return 'לא צוין';
  }

  String get secondaryMuscles {
    final secondaryMuscles = exercise.secondaryMuscles;
    if (secondaryMuscles != null && secondaryMuscles.isNotEmpty) {
      return secondaryMuscles.join(', ');
    }
    return '';
  }
}
