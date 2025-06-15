import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/workouts_provider.dart';
import '../../../theme/app_theme.dart';
import '../widgets/stats_charts.dart';
import '../widgets/stats_summary.dart';
import '../services/stats_export_service.dart';

class WorkoutStatsScreen extends StatefulWidget {
  const WorkoutStatsScreen({super.key});

  @override
  State<WorkoutStatsScreen> createState() => _WorkoutStatsScreenState();
}

class _WorkoutStatsScreenState extends State<WorkoutStatsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String _selectedPeriod = 'שבוע';
  bool _isExporting = false;

  static const List<String> _periods = ['שבוע', 'חודש', 'שנה'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportStats() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final workouts = context.read<WorkoutsProvider>().workouts;
      final workoutsData = workouts.map((w) => w.toMap()).toList();
      await StatsExportService.exportStats(workoutsData);

      if (mounted) {
        _showSuccessSnackBar('הנתונים יוצאו בהצלחה!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('שגיאה בייצוא הנתונים: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          title: Text(
            'סטטיסטיקות אימונים',
            style: GoogleFonts.assistant(
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          actions: [
            IconButton(
              icon: _isExporting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.primary),
                      ),
                    )
                  : const Icon(Icons.share_outlined),
              onPressed: _isExporting ? null : _exportStats,
              tooltip: 'ייצוא נתונים',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: colors.primary,
            labelColor: colors.primary,
            unselectedLabelColor: colors.text.withOpacity(0.6),
            labelStyle: GoogleFonts.assistant(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'סקירה'),
              Tab(icon: Icon(Icons.trending_up_outlined), text: 'התקדמות'),
              Tab(icon: Icon(Icons.emoji_events_outlined), text: 'הישגים'),
            ],
          ),
        ),
        body: Consumer<WorkoutsProvider>(
          builder: (context, provider, child) {
            final workouts = provider.workouts;

            if (workouts.isEmpty) {
              return _buildEmptyState();
            }

            final workoutsData = workouts.map((w) => w.toMap()).toList();

            return Column(
              children: [
                _buildPeriodSelector(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(workoutsData),
                      _buildProgressTab(workoutsData),
                      _buildAchievementsTab(workoutsData),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = AppTheme.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: colors.text.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'אין נתונים להצגה',
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'התחל להתאמן כדי לראות סטטיסטיקות מפורטות',
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: colors.text.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.fitness_center),
            label: Text(
              'התחל להתאמן',
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final colors = AppTheme.colors;

    return Container(
      margin: const EdgeInsets.all(16),
      child: SegmentedButton<String>(
        segments: _periods.map((period) {
          IconData icon;
          switch (period) {
            case 'שבוע':
              icon = Icons.calendar_today;
              break;
            case 'חודש':
              icon = Icons.calendar_month;
              break;
            case 'שנה':
              icon = Icons.calendar_view_month;
              break;
            default:
              icon = Icons.calendar_today;
          }

          return ButtonSegment(
            value: period,
            label: Text(
              period,
              style: GoogleFonts.assistant(fontWeight: FontWeight.w600),
            ),
            icon: Icon(icon),
          );
        }).toList(),
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedPeriod = newSelection.first;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return colors.primary;
              }
              return colors.surface;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return colors.primary;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(List<Map<String, dynamic>> workoutsData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCard(
            workouts: workoutsData,
            period: _selectedPeriod,
          ),
          const SizedBox(height: 20),
          _buildQuickStats(workoutsData),
          const SizedBox(height: 20),
          WorkoutsChart(
            workouts: workoutsData,
            period: _selectedPeriod,
          ),
          const SizedBox(height: 20),
          DurationChart(
            workouts: workoutsData,
            period: _selectedPeriod,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(List<Map<String, dynamic>> workoutsData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ExerciseProgressChart(
            workouts: workoutsData,
          ),
          const SizedBox(height: 20),
          _buildWeightProgressChart(),
          const SizedBox(height: 20),
          _buildConsistencyChart(),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(List<Map<String, dynamic>> workoutsData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AchievementsCard(
            workouts: workoutsData,
          ),
          const SizedBox(height: 20),
          _buildPersonalRecords(),
          const SizedBox(height: 20),
          _buildStreakCard(),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Map<String, dynamic>> workoutsData) {
    final colors = AppTheme.colors;

    // חישובי סטטיסטיקות בסיסיים
    final totalWorkouts = workoutsData.length;
    final totalDuration = workoutsData.fold<int>(
      0,
      (sum, workout) => sum + ((workout['duration'] as int?) ?? 30),
    );
    final avgDuration =
        totalWorkouts > 0 ? (totalDuration / totalWorkouts).round() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'סך אימונים',
            totalWorkouts.toString(),
            Icons.fitness_center,
            colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'זמן ממוצע',
            '$avgDuration דק\'',
            Icons.timer,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'סך זמן',
            '${(totalDuration / 60).toStringAsFixed(1)} שעות',
            Icons.schedule,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.text.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressChart() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'התקדמות במשקלים',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colors.text.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.assistant(
                            fontSize: 12,
                            color: colors.text.withOpacity(0.7),
                          ),
                        );
                      },
                      reservedSize: 35,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt() + 1}',
                          style: GoogleFonts.assistant(
                            fontSize: 12,
                            color: colors.text.withOpacity(0.7),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateProgressData(),
                    isCurved: true,
                    color: colors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: colors.primary,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        );
                      },
                    ),
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
      ),
    );
  }

  Widget _buildConsistencyChart() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: colors.secondary),
              const SizedBox(width: 8),
              Text(
                'עקביות אימונים',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildConsistencyGrid(),
        ],
      ),
    );
  }

  Widget _buildConsistencyGrid() {
    final colors = AppTheme.colors;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 49, // 7 שבועות
      itemBuilder: (context, index) {
        final date = today.subtract(Duration(days: 48 - index));
        final hasWorkout = _hasWorkoutOnDate(date);

        return Container(
          decoration: BoxDecoration(
            color: hasWorkout ? colors.primary : colors.text.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: hasWorkout
              ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
              : null,
        );
      },
    );
  }

  Widget _buildPersonalRecords() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'שיאים אישיים',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecordItem(
              'משקל מקסימלי', '120 ק"ג', 'דחיפת חזה', Icons.fitness_center),
          const SizedBox(height: 12),
          _buildRecordItem(
              'אימון הכי ארוך', '95 דקות', 'אימון גב ובטן', Icons.timer),
          const SizedBox(height: 12),
          _buildRecordItem(
              'הכי הרבה חזרות', '25 חזרות', 'סקוואט', Icons.repeat),
          const SizedBox(height: 12),
          _buildRecordItem('הכי הרבה סטים', '8 סטים', 'אימון זרועות',
              Icons.format_list_numbered),
        ],
      ),
    );
  }

  Widget _buildRecordItem(
      String title, String value, String description, IconData icon) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.headline,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.assistant(
                    fontSize: 12,
                    color: colors.text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.trending_up,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withOpacity(0.1),
            colors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'רצף אימונים נוכחי',
                      style: GoogleFonts.assistant(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.headline,
                      ),
                    ),
                    Text(
                      '7 ימים רצופים',
                      style: GoogleFonts.assistant(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStreakStat('הכי ארוך', '14 ימים', Icons.timeline),
              ),
              Container(
                height: 40,
                width: 1,
                color: colors.primary.withOpacity(0.3),
              ),
              Expanded(
                child:
                    _buildStreakStat('השבוע', '5/7 ימים', Icons.calendar_today),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakStat(String title, String value, IconData icon) {
    final colors = AppTheme.colors;

    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.assistant(
            fontSize: 12,
            color: colors.text.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Helper methods
  List<FlSpot> _generateProgressData() {
    return [
      const FlSpot(0, 40),
      const FlSpot(1, 45),
      const FlSpot(2, 42),
      const FlSpot(3, 50),
      const FlSpot(4, 55),
      const FlSpot(5, 52),
      const FlSpot(6, 60),
      const FlSpot(7, 58),
      const FlSpot(8, 65),
      const FlSpot(9, 70),
    ];
  }

  bool _hasWorkoutOnDate(DateTime date) {
    return date.day % 3 == 0;
  }
}
