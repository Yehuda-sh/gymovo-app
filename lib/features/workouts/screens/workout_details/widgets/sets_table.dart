// lib/features/workouts/screens/workout_details/widgets/sets_table.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../models/workout_model.dart';

class SetsTable extends StatelessWidget {
  final ExerciseModel exercise;

  const SetsTable({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: colors.outline),
        columnWidths: const {
          0: FlexColumnWidth(1), // סט
          1: FlexColumnWidth(2), // משקל
          2: FlexColumnWidth(2), // חזרות
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // כותרת
          TableRow(
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            children: [
              _buildHeaderCell('סט', colors),
              _buildHeaderCell('משקל (ק"ג)', colors),
              _buildHeaderCell('חזרות', colors),
            ],
          ),
          // שורות הסטים
          ...exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: index % 2 == 0 ? colors.surface : colors.background,
              ),
              children: [
                _buildCell('${index + 1}', colors),
                _buildCell(set.weight.toString(), colors),
                _buildCell(set.reps.toString(), colors),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.assistant(
          fontWeight: FontWeight.bold,
          color: colors.text,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.assistant(
          color: colors.text,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
