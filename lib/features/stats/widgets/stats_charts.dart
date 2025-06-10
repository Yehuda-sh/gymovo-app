import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutsChart extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final String period;

  const WorkoutsChart({
    super.key,
    required this.workouts,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'אימונים לפי $period',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
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
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.assistant(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.7),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      color: colors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
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
      ),
    );
  }

  List<FlSpot> _getSpots() {
    final spots = <FlSpot>[];
    final now = DateTime.now();
    var startDate = now;

    switch (period) {
      case 'שבוע':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'חודש':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'שנה':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
    }

    final filteredWorkouts = workouts.where((w) {
      final date = DateTime.parse(w['completed_at'] as String);
      return date.isAfter(startDate) && date.isBefore(now);
    }).toList();

    for (var i = 0; i < filteredWorkouts.length; i++) {
      spots.add(FlSpot(i.toDouble(), 1));
    }

    return spots;
  }
}

class DurationChart extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  final String period;

  const DurationChart({
    super.key,
    required this.workouts,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'זמן אימון לפי $period',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} דק',
                            style: GoogleFonts.assistant(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.7),
                            ),
                          );
                        },
                      ),
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
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.assistant(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.7),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _getBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    final now = DateTime.now();
    var startDate = now;

    switch (period) {
      case 'שבוע':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'חודש':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'שנה':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
    }

    final filteredWorkouts = workouts.where((w) {
      final date = DateTime.parse(w['completed_at'] as String);
      return date.isAfter(startDate) && date.isBefore(now);
    }).toList();

    return List.generate(filteredWorkouts.length, (index) {
      final workout = filteredWorkouts[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (workout['duration'] as int).toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }
}

class ExerciseProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;

  const ExerciseProgressChart({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'התקדמות בתרגילים',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _getSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    final exerciseStats = <String, int>{};

    for (final workout in workouts) {
      for (final exercise in workout['exercises'] as List) {
        exerciseStats[exercise['name'] as String] =
            (exerciseStats[exercise['name'] as String] ?? 0) +
                (exercise['sets'] as List).length;
      }
    }

    final sortedExercises = exerciseStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return List.generate(
      sortedExercises.length.clamp(0, 5),
      (index) {
        final exercise = sortedExercises[index];
        final total = sortedExercises.fold<int>(0, (sum, e) => sum + e.value);
        final percentage = (exercise.value / total * 100).round();

        return PieChartSectionData(
          value: exercise.value.toDouble(),
          title: '$percentage%',
          color: colors[index % colors.length],
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
