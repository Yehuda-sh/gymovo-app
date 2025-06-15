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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return ExerciseCard(exercise: exercises[index]);
      },
    );
  }
}
