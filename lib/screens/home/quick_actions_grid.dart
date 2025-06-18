// lib/screens/home/quick_actions_grid.dart
import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onNewWorkout;
  final VoidCallback onStats;
  final VoidCallback onWeekPlan;
  final VoidCallback onProfile;
  final bool isSmallScreen;

  const QuickActionsGrid({
    super.key,
    required this.onNewWorkout,
    required this.onStats,
    required this.onWeekPlan,
    required this.onProfile,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: isSmallScreen ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isSmallScreen ? 3.5 : 1.8,
      children: [
        _buildCard('אימון חדש', Icons.add_circle_outline, onNewWorkout),
        _buildCard('סטטיסטיקות', Icons.bar_chart, onStats),
        _buildCard('תוכנית שבועית', Icons.calendar_view_week, onWeekPlan),
        _buildCard('פרופיל', Icons.person_outline, onProfile),
      ],
    );
  }

  Widget _buildCard(String label, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
