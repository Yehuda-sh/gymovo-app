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

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1), // סט
        1: FlexColumnWidth(2), // משקל
        2: FlexColumnWidth(2), // חזרות
      },
      children: [
        // כותרת
        TableRow(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
    );
  }

  Widget _buildHeaderCell(String text, AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
