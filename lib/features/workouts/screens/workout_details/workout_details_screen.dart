import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/workout_model.dart';
import 'widgets/workout_header.dart';
import 'widgets/exercise_list.dart';
import 'widgets/workout_actions.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        title: Text(
          'פרטי האימון',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          WorkoutHeader(workout: workout),
          Expanded(
            child: ExerciseList(exercises: workout.exercises),
          ),
        ],
      ),
      bottomNavigationBar: WorkoutActions(workout: workout),
    );
  }
}
