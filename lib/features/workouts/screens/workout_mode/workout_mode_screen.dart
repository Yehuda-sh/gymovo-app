// lib/features/workouts/screens/workout_mode/workout_mode_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../models/workout_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/exercise.dart';
import '../../providers/workout_mode_provider.dart';

import 'widgets/set_row.dart';
import 'widgets/exercise_progress_bar.dart';
import 'widgets/workout_complete.dart';
import 'dialogs/edit_rest_dialog.dart';
import 'dialogs/edit_set_dialog.dart';
import 'dialogs/exercise_quick_view.dart';
import 'widgets/top_bar.dart';

class WorkoutModeScreen extends StatelessWidget {
  final WorkoutModel workout;
  final Map<String, Exercise> exerciseDetailsMap;

  const WorkoutModeScreen({
    super.key,
    required this.workout,
    required this.exerciseDetailsMap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutModeProvider(
        workout: workout,
        exerciseDetailsMap: exerciseDetailsMap,
      ),
      child: const _WorkoutModeView(),
    );
  }
}

class _WorkoutModeView extends StatefulWidget {
  const _WorkoutModeView();

  @override
  State<_WorkoutModeView> createState() => _WorkoutModeViewState();
}

class _WorkoutModeViewState extends State<_WorkoutModeView> {
  Timer? _restTimer;

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final provider = context.read<WorkoutModeProvider>();
      final currentSeconds = provider.restSeconds;
      if (currentSeconds > 0) {
        provider.updateRestSeconds(currentSeconds - 1);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutModeProvider>(
      builder: (context, provider, _) {
        final colors = AppTheme.colors;
        final exercises = provider.workout.exercises;
        final detailsMap = provider.exerciseDetailsMap;

        // Start rest timer if needed
        if (provider.activeRestKey != null &&
            provider.restSeconds > 0 &&
            _restTimer == null) {
          _startRestTimer();
        }

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            title: Text(
              provider.workout.title,
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              if (provider.isWorkoutComplete)
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 6),
                  child: Chip(
                    backgroundColor: Colors.green.withAlpha(60),
                    avatar: const Icon(Icons.emoji_events,
                        color: Colors.green, size: 20),
                    label: Text(
                      "סיימת את כל האימון!",
                      style: GoogleFonts.assistant(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
            ],
          ),
          body: provider.isWorkoutComplete
              ? const WorkoutCompleteWidget()
              : Column(
                  children: [
                    WorkoutTopBar(
                      onFinishWorkout: () {
                        // כאן הפעולה שלך לסיום אימון
                        // לדוג' provider.finishWorkout(); או מעבר למסך סיום וכו'
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _buildExercisesList(
                          context, provider, exercises, detailsMap),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildExercisesList(
    BuildContext context,
    WorkoutModeProvider provider,
    List<ExerciseModel> exercises,
    Map<String, Exercise> detailsMap,
  ) {
    return ListView.builder(
      key: ValueKey(provider.isWorkoutComplete),
      padding: const EdgeInsets.all(14),
      itemCount: exercises.length,
      itemBuilder: (context, exIdx) {
        final ex = exercises[exIdx];
        final completed = provider.completedSets[ex.id] ?? {};
        final allSetsDone = completed.length == ex.sets.length;
        final exDetails = detailsMap[ex.id];

        return _ExerciseCard(
          exercise: ex,
          exerciseDetails: exDetails,
          isAllSetsDone: allSetsDone,
          provider: provider,
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final Exercise? exerciseDetails;
  final bool isAllSetsDone;
  final WorkoutModeProvider provider;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseDetails,
    required this.isAllSetsDone,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final completed = provider.completedSets[exercise.id] ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isAllSetsDone
              ? Colors.green.withAlpha(110)
              : colors.primary.withAlpha(38),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExerciseHeader(
              exercise: exercise,
              exerciseDetails: exerciseDetails,
              isAllSetsDone: isAllSetsDone,
              onEditRest: () => _showEditRestDialog(context),
            ),
            const SizedBox(height: 10),
            ExerciseProgressBar(
              total: exercise.sets.length,
              completed: completed.length,
            ),
            const SizedBox(height: 14),
            _ExerciseSetsList(
              exercise: exercise,
              provider: provider,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditRestDialog(
        exId: exercise.id,
        initialRest: provider.getRestTimeForExercise(exercise.id),
        onSave: (newRestTime) {
          provider.updateRestTime(exercise.id, newRestTime);
        },
      ),
    );
  }
}

class _ExerciseHeader extends StatelessWidget {
  final ExerciseModel exercise;
  final Exercise? exerciseDetails;
  final bool isAllSetsDone;
  final VoidCallback onEditRest;

  const _ExerciseHeader({
    required this.exercise,
    required this.exerciseDetails,
    required this.isAllSetsDone,
    required this.onEditRest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (exerciseDetails?.imageUrl != null &&
            exerciseDetails!.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              exerciseDetails!.imageUrl!,
              height: 38,
              width: 38,
              fit: BoxFit.cover,
            ),
          )
        else
          Icon(Icons.fitness_center, color: colors.primary, size: 36),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (exerciseDetails != null) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppTheme.colors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  builder: (ctx) => ExerciseQuickView(
                    exercise: exerciseDetails!,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                exercise.name,
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colors.headline,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.timer, size: 22),
          color: colors.accent,
          tooltip: 'ערוך זמן מנוחה',
          onPressed: onEditRest,
        ),
        if (isAllSetsDone)
          Icon(Icons.check_circle, color: Colors.green, size: 22),
      ],
    );
  }
}

class _ExerciseSetsList extends StatelessWidget {
  final ExerciseModel exercise;
  final WorkoutModeProvider provider;

  const _ExerciseSetsList({
    required this.exercise,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercise.sets.length,
      itemBuilder: (context, setIdx) {
        final set = exercise.sets[setIdx];
        final isDone = provider.isSetCompleted(exercise.id, setIdx);
        final isResting = provider.isSetResting(exercise.id, setIdx);

        return SetRow(
          setIdx: setIdx,
          set: set,
          isDone: isDone,
          isResting: isResting,
          restSeconds: provider.restSeconds,
          onToggleDone: () => provider.toggleSetComplete(
            exercise.id,
            setIdx,
            provider.getRestTimeForExercise(exercise.id),
          ),
          onEdit: () => _showEditSetDialog(context, setIdx, set),
        );
      },
    );
  }

  void _showEditSetDialog(BuildContext context, int setIdx, ExerciseSet set) {
    showDialog(
      context: context,
      builder: (context) => EditSetDialog(
        exId: exercise.id,
        setIdx: setIdx,
        set: set,
        onSave: (updatedSet) {
          provider.updateSet(exercise.id, setIdx, updatedSet);
        },
        onDelete: () {
          provider.deleteSet(exercise.id, setIdx);
        },
        onAdd: () {
          provider.addSet(exercise.id, setIdx);
        },
      ),
    );
  }
}
