// lib/features/exercises/widgets/exercise_history_graph.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/unified_models.dart';

class ExerciseHistoryGraph extends StatelessWidget {
  final List<ExerciseSet> sets;

  const ExerciseHistoryGraph({
    super.key,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    // סינון סטים עם משקל ותאריך תקינים
    final filteredSets = sets
        .where((s) =>
            s.weight != null &&
            s.weight! > 0 &&
            s.date.millisecondsSinceEpoch > 0)
        .toList();

    if (filteredSets.length < 2) return const SizedBox.shrink();

    // הכנת נקודות לגרף
    final spots = filteredSets.map((set) {
      final day = set.date.millisecondsSinceEpoch.toDouble();
      return FlSpot(day, set.weight!);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

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
                color: theme.colorScheme.primary,
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
