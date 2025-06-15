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
import '../../../features/workouts/screens/week_plan_screen.dart';
import 'dart:math';

class HomeTab extends StatelessWidget {
  final void Function(int) onTabChange;

  const HomeTab({Key? key, required this.onTabChange}) : super(key: key);

  // קבועים פרטיים לקלאס
  static const List<String> _demoEmails = [
    'demo1@gymovo.com',
    'demo2@gymovo.com',
    'demo3@gymovo.com',
    'demo4@gymovo.com',
    'demo5@gymovo.com',
    'demo6@gymovo.com',
    'demo7@gymovo.com',
    'demo8@gymovo.com',
    'demo9@gymovo.com',
    'demo10@gymovo.com',
  ];

  static const String _demoPassword = 'demoUser123';
  static const int _estimatedMinutesPerSet = 3;
  static const int _minWorkoutDuration = 15;
  static const int _maxWorkoutDuration = 120;

  static const List<String> _motivationalMessages = [
    'מוכנים לאימון היום?',
    'הגוף שלך יודה לך על האימון!',
    'כל יום הוא הזדמנות להיות חזק יותר',
    'התחל היום, תראה תוצאות מחר',
    'האימון הכי קשה הוא זה שלא עושים',
  ];

  Future<void> _navigateToNewWorkout(BuildContext context) async {
    try {
      final newWorkout = WorkoutModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'אימון חדש',
        description: 'אימון חדש שנוצר עכשיו',
        createdAt: DateTime.now(),
        date: DateTime.now(),
        exercises: [],
      );

      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WorkoutModeScreen(
              workout: newWorkout,
              exerciseDetailsMap:
                  context.read<ExerciseProvider>().exerciseDetailsMap,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'שגיאה ביצירת אימון: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.assistant(),
        ),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.assistant(),
        ),
        backgroundColor: AppTheme.colors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final user = context.watch<AuthProvider>().currentUser;
    final weekPlanProvider = context.watch<WeekPlanProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        // רענון הנתונים
        await Future.wait([
          // weekPlanProvider.loadWeekPlan(),
          // context.read<AuthProvider>().refreshUserData(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(user),
              const SizedBox(height: 24),
              _buildQuickStartSection(context, weekPlanProvider),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildWorkoutProgress(context, weekPlanProvider),
              const SizedBox(height: 24),
              _buildMotivationSection(context, user),
              const SizedBox(height: 24),
              _buildStatsSection(context, weekPlanProvider),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(UserModel? user) {
    final colors = AppTheme.colors;
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'בוקר טוב';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'צהריים טובים';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'ערב טוב';
      greetingIcon = Icons.nights_stay;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.1),
            colors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                greetingIcon,
                color: colors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '$greeting, ${user?.name ?? "אורח"}!',
                style: GoogleFonts.assistant(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getMotivationalMessage(),
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: colors.text,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    return _motivationalMessages[
        Random().nextInt(_motivationalMessages.length)];
  }

  Widget _buildQuickStartSection(
      BuildContext context, WeekPlanProvider provider) {
    final colors = AppTheme.colors;
    final nextWorkout = _getNextWorkout(provider.weekPlan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('התחלה מהירה', Icons.flash_on),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: nextWorkout != null
              ? _buildNextWorkoutCard(context, nextWorkout)
              : _buildNoWorkoutCard(context),
        ),
      ],
    );
  }

  Widget _buildNextWorkoutCard(BuildContext context, WorkoutModel workout) {
    final colors = AppTheme.colors;

    return InkWell(
      onTap: () => _navigateToWorkout(context, workout),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'האימון הבא שלך',
                        style: GoogleFonts.assistant(
                          fontSize: 14,
                          color: colors.text.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        workout.title,
                        style: GoogleFonts.assistant(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.headline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildWorkoutStat(Icons.fitness_center,
                    '${workout.exercises.length} תרגילים'),
                const SizedBox(width: 16),
                _buildWorkoutStat(Icons.access_time, _formatDuration(workout)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('התחל אימון'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _navigateToWorkout(context, workout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWorkoutCard(BuildContext context) {
    final colors = AppTheme.colors;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: colors.text.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'אין אימון מתוכנן להיום',
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'בדוק את תוכנית האימונים שלך או צור אימון חדש',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: colors.text.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('צור אימון חדש'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _navigateToNewWorkout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.assistant(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final colors = AppTheme.colors;

    return Row(
      children: [
        Icon(
          icon,
          color: colors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.headline,
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
        _buildSectionHeader('פעולות מהירות', Icons.dashboard),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            QuickActionCard(
              label: 'אימון חדש',
              icon: Icons.add_circle_outline,
              color: colors.primary,
              onTap: () => _navigateToNewWorkout(context),
            ),
            QuickActionCard(
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
            QuickActionCard(
              label: 'תוכנית שבועית',
              icon: Icons.calendar_view_week,
              color: colors.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeekPlanScreen(),
                ),
              ),
            ),
            QuickActionCard(
              label: 'פרופיל',
              icon: Icons.person_outline,
              color: colors.headline,
              onTap: () => onTabChange(2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutProgress(
      BuildContext context, WeekPlanProvider weekPlanProvider) {
    final colors = AppTheme.colors;
    final totalWorkouts = weekPlanProvider.weekPlan.length;

    // חישוב אימונים שהושלמו השבוע - נתונים לדוגמה עד שתוסיף שדה isCompleted
    final completedWorkouts =
        _getCompletedWorkoutsCount(weekPlanProvider.weekPlan);

    final progressPercentage =
        totalWorkouts > 0 ? (completedWorkouts / totalWorkouts) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('התקדמות השבוע', Icons.trending_up),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'אימונים השבוע',
                      style: GoogleFonts.assistant(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.headline,
                      ),
                    ),
                    Text(
                      '$completedWorkouts/$totalWorkouts',
                      style: GoogleFonts.assistant(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: colors.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progressPercentage * 100).toInt()}% הושלם',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationSection(BuildContext context, UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('מוטיבציה ליום', Icons.psychology),
        const SizedBox(height: 16),
        MotivationCard(user: user),
      ],
    );
  }

  Widget _buildStatsSection(
      BuildContext context, WeekPlanProvider weekPlanProvider) {
    final colors = AppTheme.colors;
    final lastWorkoutDate = weekPlanProvider.lastWorkoutDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('נתונים אחרונים', Icons.analytics),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: lastWorkoutDate != null
                ? _buildStatsWithData(context, lastWorkoutDate)
                : _buildNoStatsData(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsWithData(BuildContext context, DateTime lastWorkoutDate) {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'אימון אחרון: ${_formatLastWorkoutDate(lastWorkoutDate)}',
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];
                      if (value >= 0 && value < days.length) {
                        return Text(
                          days[value.toInt()],
                          style: GoogleFonts.assistant(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _generateWeeklyData(),
                  isCurved: true,
                  color: colors.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colors.primary.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoStatsData(BuildContext context) {
    final colors = AppTheme.colors;

    return Column(
      children: [
        Icon(
          Icons.insert_chart_outlined,
          size: 48,
          color: colors.text.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'אין נתוני אימונים עדיין',
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'התחל להתאמן כדי לראות את ההתקדמות שלך',
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: colors.text.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper methods
  WorkoutModel? _getNextWorkout(List<WorkoutModel> workouts) {
    final now = DateTime.now();
    return workouts
        .where((workout) => workout.date?.isAfter(now) == true)
        .fold<WorkoutModel?>(
          null,
          (next, workout) =>
              next == null || (workout.date?.isBefore(next.date!) == true)
                  ? workout
                  : next,
        );
  }

  void _navigateToWorkout(BuildContext context, WorkoutModel workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutModeScreen(
          workout: workout,
          exerciseDetailsMap:
              context.read<ExerciseProvider>().exerciseDetailsMap,
        ),
      ),
    );
  }

  String _formatDuration(WorkoutModel workout) {
    final totalSets = workout.exercises
        .fold<int>(0, (sum, exercise) => sum + exercise.sets.length);
    final estimatedMinutes = (totalSets * _estimatedMinutesPerSet)
        .clamp(_minWorkoutDuration, _maxWorkoutDuration);
    return '$estimatedMinutes דקות';
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

  List<FlSpot> _generateWeeklyData() {
    // נתונים לדוגמה - יש להחליף בנתונים אמיתיים
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 1),
      const FlSpot(2, 4),
      const FlSpot(3, 2),
      const FlSpot(4, 5),
      const FlSpot(5, 3),
      const FlSpot(6, 4),
    ];
  }

  int _getCompletedWorkoutsCount(List<WorkoutModel> workouts) {
    // כאן תוכל להוסיף לוגיקה אמיתית לבדיקת אימונים שהושלמו
    // לדוגמה, בדיקה אם יש תאריך השלמה או שדה isCompleted

    // כרגע מחזיר נתון לדוגמה - 60% מהאימונים הושלמו
    return (workouts.length * 0.6).round();

    // כשתוסיף שדה isCompleted למודל, תוכל להחליף ל:
    // return workouts.where((workout) => workout.isCompleted ?? false).length;

    // או אם יש תאריך השלמה:
    // return workouts.where((workout) => workout.completedAt != null).length;
  }
}
