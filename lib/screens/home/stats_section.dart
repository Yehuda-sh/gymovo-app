// lib/screens/home/stats_section.dart
import 'package:flutter/material.dart';
import '../../models/workout_model.dart';

class StatsSection extends StatelessWidget {
  final DateTime? lastWorkoutDate;
  final List<WorkoutModel> workouts;

  const StatsSection({
    super.key,
    required this.lastWorkoutDate,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('סטטיסטיקות',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('אימונים השבוע: ${workouts.length}'),
            if (lastWorkoutDate != null)
              Text(
                  'אימון אחרון: ${lastWorkoutDate!.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }
}
