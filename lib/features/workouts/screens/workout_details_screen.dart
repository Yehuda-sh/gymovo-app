import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/workout_model.dart';
import 'workout_mode/workout_mode_screen.dart';
import '../providers/workouts_provider.dart';
import 'package:provider/provider.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final WorkoutModel workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
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
          _buildHeader(context),
          Expanded(
            child: _buildExercisesList(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.title,
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          if (workout.description != null) ...[
            const SizedBox(height: 8),
            Text(
              workout.description!,
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: colors.headline.withOpacity(0.7),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.fitness_center,
                label: '${workout.exercises.length} תרגילים',
                color: colors.primary,
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.calendar_today,
                label: _formatDate(workout.createdAt),
                color: colors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.assistant(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    final colors = AppTheme.colors;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = workout.exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              exercise.name,
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.bold,
                color: colors.headline,
              ),
            ),
            subtitle: Text(
              '${exercise.sets.length} סטים',
              style: GoogleFonts.assistant(
                color: colors.headline.withOpacity(0.7),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (exercise.notes != null) ...[
                      Text(
                        exercise.notes!,
                        style: GoogleFonts.assistant(
                          color: colors.headline.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildSetsTable(exercise),
                    if (exercise.restTime != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 16, color: colors.accent),
                          const SizedBox(width: 6),
                          Text(
                            'זמן מנוחה: ${exercise.restTime} שניות',
                            style: GoogleFonts.assistant(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetsTable(ExerciseModel exercise) {
    final colors = AppTheme.colors;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1), // Set number
        1: FlexColumnWidth(2), // Reps
        2: FlexColumnWidth(2), // Weight
        3: FlexColumnWidth(2), // Rest
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          children: [
            _buildTableHeader('סט'),
            _buildTableHeader('חזרות'),
            _buildTableHeader('משקל'),
            _buildTableHeader('מנוחה'),
          ],
        ),
        // Data rows
        ...exercise.sets.map((set) {
          return TableRow(
            children: [
              _buildTableCell('${exercise.sets.indexOf(set) + 1}'),
              _buildTableCell(set.reps?.toString() ?? '-'),
              _buildTableCell(set.weight != null
                  ? '${set.weight!.toStringAsFixed(1)} ק"ג'
                  : '-'),
              _buildTableCell(
                  set.restTime != null ? '${set.restTime} שניות' : '-'),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.assistant(
          fontWeight: FontWeight.bold,
          color: AppTheme.colors.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.assistant(
          color: AppTheme.colors.headline,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final colors = AppTheme.colors;
    final provider = context.read<WorkoutsProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () async {
            final exerciseDetails = await provider.getExerciseDetails(workout);
            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutModeScreen(
                  workout: workout,
                  exerciseDetailsMap: const {}, // TODO: Get actual exercise details
                ),
              ),
            );
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('התחל אימון'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
