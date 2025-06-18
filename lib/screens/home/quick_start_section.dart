// lib/screens/home/quick_start_section.dart
import 'package:flutter/material.dart';
import '../../models/workout_model.dart';

class QuickStartSection extends StatelessWidget {
  final List<WorkoutModel> weekPlan;
  final VoidCallback onNewWorkout;
  final bool isLoading;

  const QuickStartSection({
    super.key,
    required this.weekPlan,
    required this.onNewWorkout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('התחלה מהירה',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: onNewWorkout,
                child: const Text('התחל אימון חדש'),
              ),
          ],
        ),
      ),
    );
  }
}
