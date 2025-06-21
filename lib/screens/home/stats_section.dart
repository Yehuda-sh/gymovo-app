// lib/screens/home/stats_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final dateFormat = DateFormat('dd/MM/yyyy', 'he_IL');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF43e97b),
            Color(0xFF38f9d7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43e97b).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsHeader(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: Icons.fitness_center,
                      label:
                          'אימונים השבוע: ${workouts.isEmpty ? '0' : workouts.length}',
                    ),
                    const SizedBox(height: 16),
                    _StatRow(
                      icon: Icons.schedule,
                      label: lastWorkoutDate != null
                          ? 'אימון אחרון: ${dateFormat.format(lastWorkoutDate!.toLocal())}'
                          : 'אימון אחרון: ---',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(Icons.analytics, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        const Text(
          'סטטיסטיקות',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatRow({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
