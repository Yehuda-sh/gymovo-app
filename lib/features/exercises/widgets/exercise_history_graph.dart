import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/exercise_history.dart';

class ExerciseHistoryGraph extends StatelessWidget {
  final List<ExerciseSet> sets;

  const ExerciseHistoryGraph({
    super.key,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    if (sets.length < 2) return const SizedBox.shrink();

    // מניעת טעויות: רק סטים עם תאריך ומשקל
    final filteredSets =
        sets.where((s) => s.weight != null).toList();
    if (filteredSets.length < 2) return const SizedBox.shrink();

    final spots = filteredSets.map((set) {
      final day = set.date.millisecondsSinceEpoch.toDouble();
      return FlSpot(day, set.weight.toDouble());
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));

    final minX = spots.first.x;
    final maxX = spots.last.x;

    final theme = Theme.of(context);

    return Semantics(
      label: 'גרף היסטוריית משקל סטים',
      child: SizedBox(
        height: 120,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 4,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                color: theme.colorScheme.primary, // צבע דינמי!
              ),
            ],
            minX: minX,
            maxX: maxX,
          ),
        ),
      ),
    );
  }
}
