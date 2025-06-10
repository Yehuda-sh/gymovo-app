import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/week_plan_provider.dart';
import '../../../providers/exercise_provider.dart';
import '../../../models/workout_model.dart';
import '../../../models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../widgets/quick_action_card.dart';
import '../../../features/motivation/widgets/motivation_card.dart';
import '../../../features/workouts/screens/workout_mode/workout_mode_screen.dart';
import '../../../features/stats/screens/workout_stats_screen.dart';
import 'dart:math';

class HomeTab extends StatelessWidget {
  final void Function(int) onTabChange;
  const HomeTab({Key? key, required this.onTabChange}) : super(key: key);

  static final List<String> demoEmails =
      List.generate(10, (i) => 'demo${i + 1}@gymovo.com');
  static const String demoPassword = 'demoUser123';

  void _navigateToNewWorkout(BuildContext context) {
    final newWorkout = WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'אימון חדש',
      description: 'אימון חדש שנוצר עכשיו',
      date: DateTime.now(),
      exercises: [],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutModeScreen(
          workout: newWorkout,
          exerciseDetailsMap:
              context.read<ExerciseProvider>().exerciseDetailsMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final user = context.watch<AuthProvider>().currentUser;
    // TODO: Implement week plan provider
    // final weekPlan = context.watch<WeekPlanProvider>().currentWeekPlan;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(user),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            // TODO: Implement workout progress section
            // _buildWorkoutProgress(context, weekPlan),
            const SizedBox(height: 24),
            _buildMotivationSection(context),
            const SizedBox(height: 24),
            _buildStatsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(UserModel? user) {
    final colors = AppTheme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'שלום, ${user?.name ?? "אורח"}!',
          style: GoogleFonts.assistant(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Text(
          'מוכנים לאימון היום?',
          style: GoogleFonts.assistant(
            fontSize: 16,
            color: colors.text,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final colors = AppTheme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'פעולות מהירות',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                label: 'אימון חדש',
                icon: Icons.add_circle_outline,
                color: colors.primary,
                onTap: () => _navigateToNewWorkout(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionCard(
                label: 'סטטיסטיקות',
                icon: Icons.bar_chart,
                color: colors.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutStatsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutProgress(BuildContext context, dynamic weekPlan) {
    // TODO: Implement workout progress section
    return Container(); // Placeholder
  }

  Widget _buildMotivationSection(BuildContext context) {
    final colors = AppTheme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'מוטיבציה ליום',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        const MotivationCard(
          user: null, // TODO: Pass actual user
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    // TODO: Implement stats section
    return Container(); // Placeholder
  }
}
