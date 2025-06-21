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
      childAspectRatio: isSmallScreen ? 4 : 2.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _SportCard(
          label: 'אימון חדש',
          icon: Icons.fitness_center,
          onTap: onNewWorkout,
          gradientColors: const [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
          iconColor: Colors.white,
        ),
        _SportCard(
          label: 'סטטיסטיקות',
          icon: Icons.trending_up,
          onTap: onStats,
          gradientColors: const [
            Color(0xFFf093fb),
            Color(0xFFf5576c),
          ],
          iconColor: Colors.white,
        ),
        _SportCard(
          label: 'תוכנית שבועית',
          icon: Icons.calendar_today,
          onTap: onWeekPlan,
          gradientColors: const [
            Color(0xFF4facfe),
            Color(0xFF00f2fe),
          ],
          iconColor: Colors.white,
        ),
        _SportCard(
          label: 'פרופיל',
          icon: Icons.person,
          onTap: onProfile,
          gradientColors: const [
            Color(0xFF43e97b),
            Color(0xFF38f9d7),
          ],
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class _SportCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final Color iconColor;

  const _SportCard({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradientColors,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, size: 32, color: iconColor),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
