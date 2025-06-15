// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/week_plan_provider.dart';
import '../widgets/greeting_header.dart';
import '../theme/app_theme.dart';
import '../models/workout_model.dart';

import '../models/user_model.dart';
import 'splash_screen.dart';
import 'profile_screen.dart';
import 'workouts_screen.dart';
import '../features/workouts/screens/workout_mode/workout_mode_screen.dart';
import 'week_plan_screen.dart';
import 'settings_screen.dart';
import '../features/stats/screens/workout_stats_screen.dart';
import 'dart:math';
import '../providers/exercise_provider.dart';
import '../features/motivation/widgets/motivation_card.dart';
import '../features/home/widgets/quick_action_card.dart';
import '../features/home/screens/home_tab.dart';

// מסכים נוספים

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(onTabChange: _onItemTapped),
      const WorkoutsScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final colors = AppTheme.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'התנתקות',
            style: GoogleFonts.assistant(color: colors.text),
            textDirection: TextDirection.rtl,
          ),
          content: Text(
            'האם אתה בטוח שברצונך להתנתק?',
            style: GoogleFonts.assistant(color: colors.text),
            textDirection: TextDirection.rtl,
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ביטול',
                style: GoogleFonts.assistant(
                    color: Colors.blue, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'התנתק',
                style: GoogleFonts.assistant(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/gymovo_logo.png',
              height: 36,
            ),
            const SizedBox(width: 10),
            Text(
              'Gymovo',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                color: colors.headline,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colors.headline),
            tooltip: 'התנתק',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: colors.surface,
        indicatorColor: colors.headline.withAlpha(30),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: colors.headline),
            selectedIcon: Icon(Icons.home, color: colors.headline),
            label: 'בית',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined, color: colors.headline),
            selectedIcon: Icon(Icons.fitness_center, color: colors.headline),
            label: 'אימונים',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: colors.headline),
            selectedIcon: Icon(Icons.person, color: colors.headline),
            label: 'פרופיל',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: colors.headline),
            selectedIcon: Icon(Icons.settings, color: colors.headline),
            label: 'הגדרות',
          ),
        ],
      ),
    );
  }
}

// ================== טאב הבית ==================
class _HomeTab extends StatelessWidget {
  final void Function(int) onTabChange;
  const _HomeTab({Key? key, required this.onTabChange}) : super(key: key);

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

  Future<void> _loginAsDemoUser(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final random = Random();
    final email = demoEmails[random.nextInt(demoEmails.length)];

    await authProvider.loginAsDemoUser();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'התחברת בהצלחה כמשתמש דמו 🎉',
            style: GoogleFonts.assistant(),
          ),
          backgroundColor: AppTheme.colors.secondary,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ההתחברות כמשתמש דמו נכשלה. אנא נסה שוב.',
            style: GoogleFonts.assistant(),
          ),
          backgroundColor: AppTheme.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final authProvider = context.watch<AuthProvider>();
    final weekPlanProvider = context.watch<WeekPlanProvider>();
    final user = authProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreetingHeader(user: user ?? UserModel.empty()),
          const SizedBox(height: 12),
          // Quick Start Section
          Text(
            'התחלה מהירה',
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuickStartCard(context, weekPlanProvider),
          const SizedBox(height: 16),
          // Quick Actions Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              _QuickActionCard(
                icon: Icons.view_week,
                label: 'תוכנית אימונים',
                color: colors.headline,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const WeekPlanScreen(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.person_outline,
                label: 'פרופיל',
                color: colors.headline,
                onTap: () => onTabChange(2),
              ),
              _QuickActionCard(
                icon: Icons.settings_outlined,
                label: 'הגדרות',
                color: colors.headline,
                onTap: () => onTabChange(3),
              ),
              _QuickActionCard(
                icon: Icons.history,
                label: 'היסטוריית אימונים',
                color: colors.headline,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorkoutStatsScreen(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                icon: Icons.fitness_center,
                label: 'אימון חדש',
                color: colors.primary,
                onTap: () => _navigateToNewWorkout(context),
              ),
              _QuickActionCard(
                icon: Icons.assessment,
                label: 'תוצאות שאלון',
                color: colors.accent,
                onTap: () {
                  // TODO: Implement questionnaire results screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'מסך תוצאות השאלון יפותח בקרוב',
                        style: GoogleFonts.assistant(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Workout Stats Section
          Text(
            'סטטיסטיקות אימונים',
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 10),
          _buildWorkoutStats(context, weekPlanProvider),
          const SizedBox(height: 20),
          MotivationCard(user: user),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(BuildContext context, WeekPlanProvider provider) {
    final nextWorkout = provider.weekPlan.isNotEmpty
        ? _getNextWorkout(provider.weekPlan)
        : null;

    if (nextWorkout == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'אין אימון מתוכנן',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'בדוק את תוכנית האימונים שלך או צור אימון חדש',
                style: GoogleFonts.assistant(fontSize: 13),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('צור אימון חדש'),
                  onPressed: () => _navigateToNewWorkout(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutModeScreen(
                workout: nextWorkout,
                exerciseDetailsMap:
                    context.read<ExerciseProvider>().exerciseDetailsMap,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.flash_on,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'האימון הבא שלך',
                    style: GoogleFonts.assistant(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nextWorkout.title,
                style: GoogleFonts.assistant(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '${nextWorkout.exercises.length} תרגילים • ${_formatDuration(nextWorkout)}',
                style: GoogleFonts.assistant(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('התחל אימון'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkoutModeScreen(
                          workout: nextWorkout,
                          exerciseDetailsMap: context
                              .read<ExerciseProvider>()
                              .exerciseDetailsMap,
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(WorkoutModel workout) {
    final totalSets = workout.exercises
        .fold<int>(0, (sum, exercise) => sum + exercise.sets.length);
    final estimatedMinutes =
        (totalSets * 3).clamp(15, 120); // 3 minutes per set
    return '$estimatedMinutes דקות';
  }

  Widget _buildWorkoutStats(BuildContext context, WeekPlanProvider provider) {
    final lastWorkoutDate = provider.lastWorkoutDate;
    if (lastWorkoutDate == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'אין נתוני אימונים',
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'התחל להתאמן כדי לראות סטטיסטיקות',
                style: GoogleFonts.assistant(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'אימון אחרון: ${_formatLastWorkoutDate(lastWorkoutDate)}',
              style: GoogleFonts.assistant(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];
                          if (value >= 0 && value < days.length) {
                            return Text(days[value.toInt()]);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 1),
                        const FlSpot(2, 4),
                        const FlSpot(3, 2),
                        const FlSpot(4, 5),
                        const FlSpot(5, 3),
                        const FlSpot(6, 4),
                      ],
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  WorkoutModel? _getNextWorkout(List<WorkoutModel> workouts) {
    final now = DateTime.now();
    return workouts
        .where((workout) => workout.date.isAfter(now))
        .fold<WorkoutModel?>(
          null,
          (next, workout) =>
              next == null || workout.date.isBefore(next.date) ? workout : next,
        );
  }

  String _formatLastWorkoutDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'היום';
    } else if (difference.inDays == 1) {
      return 'אתמול';
    } else if (difference.inDays < 7) {
      return 'לפני ${difference.inDays} ימים';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// --------- כרטיס פעולה מהירה ---------
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        splashColor: color.withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.assistant(
                  color: colors.headline,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
