import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/exercise_history.dart';

class ExerciseHistoryGraph extends StatelessWidget {
  final List<ExerciseSet> sets;

  const ExerciseHistoryGraph({
    Key? key,
    required this.sets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sets.length < 2) return const SizedBox.shrink();

    final spots = sets.map((set) {
      final day = set.date.millisecondsSinceEpoch.toDouble();
      return FlSpot(day, set.weight ?? 0);
    }).toList();

    spots.sort((a, b) => a.x.compareTo(b.x));

    final minX = spots.first.x;
    final maxX = spots.last.x;

    return SizedBox(
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
              color: Colors.teal,
            ),
          ],
          minX: minX,
          maxX: maxX,
        ),
      ),
    );
  }
}
