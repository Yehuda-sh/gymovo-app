// lib/screens/home/home_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'greeting_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/week_plan_provider.dart';
import '../../models/workout_model.dart';
import '../../features/stats/screens/workout_stats_screen.dart';
import '../../features/workouts/screens/week_plan_screen.dart';

class HomeTab extends StatelessWidget {
  final void Function(int) onTabChange;
  const HomeTab({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    void goToNewWorkout() => Navigator.of(context).pushNamed('/workouts');

    void showPlaceholderSnack(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: הוספת רפרש אמיתי בעתיד
      },
      color: Theme.of(context).colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingWidget(
              user: context.read<AuthProvider>().currentUser,
            ),
            const SizedBox(height: 28),
            _QuickStartCard(onNewWorkout: goToNewWorkout),
            const SizedBox(height: 32),
            _QuickActionsGrid(
              onNewWorkout: goToNewWorkout,
              onStats: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WorkoutStatsScreen()),
              ),
              onWeekPlan: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WeekPlanScreen()),
              ),
              onProfile: () => onTabChange(2),
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 32),
            const _WorkoutProgressCard(),
            const SizedBox(height: 32),
            const _StatsCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ----- התחלה מהירה -----
class _QuickStartCard extends StatelessWidget {
  final VoidCallback onNewWorkout;

  const _QuickStartCard({required this.onNewWorkout});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.1),
            colors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'התחלה מהירה',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: const Icon(Icons.fitness_center_rounded, size: 28),
                label: const Text(
                  'התחל אימון חדש',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: colors.primary.withOpacity(0.15),
                ),
                onPressed: onNewWorkout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----- פעולות מהירות - גריד -----
class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onNewWorkout;
  final VoidCallback onStats;
  final VoidCallback onWeekPlan;
  final VoidCallback onProfile;
  final bool isSmallScreen;

  const _QuickActionsGrid({
    required this.onNewWorkout,
    required this.onStats,
    required this.onWeekPlan,
    required this.onProfile,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: isSmallScreen ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isSmallScreen ? 4.3 : 2.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _GridActionCard(
          label: 'אימון חדש',
          icon: Icons.fitness_center,
          onTap: onNewWorkout,
          gradientColors: const [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        _GridActionCard(
          label: 'סטטיסטיקות',
          icon: Icons.trending_up,
          onTap: onStats,
          gradientColors: const [
            Color(0xFFf093fb),
            Color(0xFFf5576c),
          ],
        ),
        _GridActionCard(
          label: 'תוכנית שבועית',
          icon: Icons.calendar_today,
          onTap: onWeekPlan,
          gradientColors: const [
            Color(0xFF4facfe),
            Color(0xFF00f2fe),
          ],
        ),
        _GridActionCard(
          label: 'פרופיל',
          icon: Icons.person,
          onTap: onProfile,
          gradientColors: const [
            Color(0xFF43e97b),
            Color(0xFF38f9d7),
          ],
        ),
      ],
    );
  }
}

class _GridActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const _GridActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradientColors,
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
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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

// ----- כרטיס התקדמות שבועית -----
class _WorkoutProgressCard extends StatelessWidget {
  const _WorkoutProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weekPlanProvider = context.watch<WeekPlanProvider>();
    final workouts = weekPlanProvider.weekPlan;
    final total = workouts.length;
    final completed = total ~/ 2; // TODO: החלף בלוגיקה אמיתית
    final percentage = total == 0 ? 0.0 : completed / total;
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFf093fb),
            Color(0xFFf5576c),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf093fb).withOpacity(0.4),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.trending_up,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'התקדמות השבוע',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.2),
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'הושלמו $completed מתוך $total אימונים',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    '${(percentage * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----- כרטיס סטטיסטיקות -----
class _StatsCard extends StatelessWidget {
  const _StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: להוסיף נתונים אמיתיים בעתיד
    final colors = Theme.of(context).colorScheme;

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.analytics,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'סטטיסטיקות',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Column(
                children: const [
                  _StatRow(
                    icon: Icons.fitness_center,
                    label: 'אימונים השבוע',
                    value: '0',
                  ),
                  SizedBox(height: 12),
                  _StatRow(
                    icon: Icons.schedule,
                    label: 'אימון אחרון',
                    value: '---',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: $value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
