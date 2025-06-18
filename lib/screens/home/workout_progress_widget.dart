// lib/screens/home/workout_progress_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/week_plan_provider.dart';
import '../../models/workout_model.dart';

class WorkoutProgressWidget extends StatelessWidget {
  final Animation<double>? animation;
  const WorkoutProgressWidget({super.key, this.animation});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeekPlanProvider>(
      builder: (context, weekPlanProvider, child) {
        final workouts = weekPlanProvider.weekPlan;
        final total = workouts.length;
        final completed = total ~/ 2; // דוגמה בלבד
        final percentage = total == 0 ? 0.0 : completed / total;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('התקדמות השבוע',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: percentage),
                const SizedBox(height: 8),
                Text('הושלמו $completed מתוך $total אימונים'),
              ],
            ),
          ),
        );
      },
    );
  }
}
