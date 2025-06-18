// lib/screens/home/home_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'greeting_widget.dart';
import 'quick_start_section.dart';
import 'quick_actions_grid.dart';
import 'workout_progress_widget.dart';
import 'stats_section.dart';
import '../../providers/auth_provider.dart';
import '../../providers/week_plan_provider.dart';

class HomeTab extends StatelessWidget {
  final void Function(int) onTabChange;
  const HomeTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    return RefreshIndicator(
      onRefresh: () async {},
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ברכה
              GreetingWidget(
                user: context.read<AuthProvider>().currentUser,
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              // התחלה מהירה
              QuickStartSection(
                weekPlan: context.read<WeekPlanProvider>().weekPlan,
                onNewWorkout: () {},
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              // פעולות מהירות
              QuickActionsGrid(
                onNewWorkout: () {},
                onStats: () {},
                onWeekPlan: () {},
                onProfile: () => onTabChange(2),
                isSmallScreen: isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 16 : 24),
              // התקדמות שבועית
              WorkoutProgressWidget(),
              SizedBox(height: isSmallScreen ? 16 : 24),
              // סטטיסטיקות
              StatsSection(
                lastWorkoutDate: null,
                workouts: const [],
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
            ],
          ),
        ),
      ),
    );
  }
}
