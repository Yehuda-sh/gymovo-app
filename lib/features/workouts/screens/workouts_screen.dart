import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/workout_model.dart';
import '../providers/workouts_provider.dart';
import 'new_workout_screen.dart';
import 'workout_details_screen.dart';
import 'workout_mode/workout_mode_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutsProvider(),
      child: const _WorkoutsView(),
    );
  }
}

class _WorkoutsView extends StatelessWidget {
  const _WorkoutsView();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final provider = context.watch<WorkoutsProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'האימונים שלי',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.workouts.isEmpty
              ? _buildEmptyState(context)
              : _buildWorkoutsList(context, provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewWorkout(context),
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add),
        label: Text(
          'אימון חדש',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = AppTheme.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              size: 80, color: colors.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'אין לך אימונים עדיין',
            style: GoogleFonts.assistant(
              fontSize: 20,
              color: colors.headline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'התחל ליצור אימונים חדשים',
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: colors.headline.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToNewWorkout(context),
            icon: const Icon(Icons.add),
            label: const Text('צור אימון חדש'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutsList(BuildContext context, WorkoutsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.workouts.length,
      itemBuilder: (context, index) {
        final workout = provider.workouts[index];
        return _WorkoutCard(workout: workout);
      },
    );
  }

  void _navigateToNewWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewWorkoutScreen()),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;

  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final provider = context.read<WorkoutsProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToWorkoutDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workout.title,
                      style: GoogleFonts.assistant(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.headline,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: colors.headline),
                    onSelected: (value) => _handleMenuAction(context, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('ערוך'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('מחק'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${workout.exercises.length} תרגילים',
                style: GoogleFonts.assistant(
                  color: colors.headline.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _navigateToWorkoutDetails(context),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('פרטים'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _startWorkout(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('התחל אימון'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWorkoutDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(workout: workout),
      ),
    );
  }

  void _startWorkout(BuildContext context) async {
    final provider = context.read<WorkoutsProvider>();
    final exerciseDetails = await provider.getExerciseDetails(workout);

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutModeScreen(
          workout: workout,
          exerciseDetailsMap: exerciseDetails,
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    final provider = context.read<WorkoutsProvider>();

    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewWorkoutScreen(workout: workout),
          ),
        );
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('מחק אימון'),
            content: const Text('האם אתה בטוח שברצונך למחוק את האימון?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ביטול'),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteWorkout(workout.id);
                  Navigator.pop(context);
                },
                child: const Text('מחק'),
              ),
            ],
          ),
        );
        break;
    }
  }
}
