// lib/widgets/completed_sets_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/exercise_history.dart';
import '../../theme/app_theme.dart';

class CompletedSetsList extends StatelessWidget {
  final List<ExerciseSet> completedSets;
  final String currentExerciseId;
  final int? maxSetsToShow;

  const CompletedSetsList({
    super.key,
    required this.completedSets,
    required this.currentExerciseId,
    this.maxSetsToShow,
  });

  @override
  Widget build(BuildContext context) {
    // מיון לפי תאריך חדש->ישן והגנה
    final currentExerciseSets = completedSets
        .where((set) => set.exerciseId == currentExerciseId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (currentExerciseSets.isEmpty) {
      return const SizedBox.shrink();
    }

    final setsToShow = maxSetsToShow != null
        ? currentExerciseSets.take(maxSetsToShow!).toList()
        : currentExerciseSets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'סטים שהושלמו:',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.headline,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.colors.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.colors.primary.withAlpha(60),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: setsToShow.asMap().entries.map((entry) {
              final idx = entry.key;
              final set = entry.value;
              return ListTile(
                key: ValueKey(set.id),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green[400], size: 20),
                    const SizedBox(width: 5),
                    Text(
                      'סט ${idx + 1}',
                      style: GoogleFonts.assistant(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colors.headline,
                      ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${set.weight} ק"ג × ${set.reps} ח',
                  style: GoogleFonts.assistant(
                    fontSize: 15,
                    color: AppTheme.colors.primary,
                  ),
                ),
                title: (set.notes != null && set.notes!.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          set.notes!,
                          style: GoogleFonts.assistant(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : null,
                // אפשר להוסיף פה תאריך או אייקון נוסף לפי הצורך
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
