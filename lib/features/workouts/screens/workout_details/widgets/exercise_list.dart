// lib/features/workouts/screens/workout_details/widgets/exercise_list.dart
import 'package:flutter/material.dart';
import '../../../../../models/workout_model.dart';
import 'exercise_card.dart';

class ExerciseList extends StatelessWidget {
  final List<ExerciseModel> exercises;

  const ExerciseList({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return ExerciseCard(
          key: ValueKey(exercise.id), // מפתח ייחודי לכל כרטיס
          exercise: exercise,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}
