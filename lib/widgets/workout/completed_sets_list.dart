// lib/widgets/workout/completed_sets_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/unified_models.dart';

class CompletedSetsList extends StatelessWidget {
  final List<ExerciseSet> completedSets;
  final String currentExerciseId;
  final int? maxSetsToShow;
  final bool showAnimation;
  final VoidCallback? onTap;

  const CompletedSetsList({
    super.key,
    required this.completedSets,
    required this.currentExerciseId,
    this.maxSetsToShow,
    this.showAnimation = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // סינון סטים שהושלמו לתרגיל הנוכחי
    final currentExerciseSets = completedSets
        .where((set) => set.exerciseId == currentExerciseId && set.isCompleted)
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
        _buildHeader(setsToShow.length),
        const SizedBox(height: 12),
        _buildSetsContainer(setsToShow),
        if (currentExerciseSets.length > (maxSetsToShow ?? 0) &&
            maxSetsToShow != null)
          _buildShowMoreButton(currentExerciseSets.length - maxSetsToShow!),
      ],
    );
  }

  /// בניית כותרת הרשימה
  Widget _buildHeader(int setsCount) {
    return Row(
      children: [
        Tooltip(
          message: 'היסטוריית סטים',
          child: Icon(
            Icons.history,
            size: 20,
            color: AppTheme.colors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: 'כותרת סטים שהושלמו',
          value: '$setsCount סטים שהושלמו',
          child: Text(
            'סטים שהושלמו ($setsCount)',
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
        ),
        const Spacer(),
        if (setsCount > 0)
          Semantics(
            label: 'כל הסטים הושלמו',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                '✓ הושלם',
                style: GoogleFonts.assistant(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// בניית מכולה הסטים
  Widget _buildSetsContainer(List<ExerciseSet> sets) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.colors.surface.withOpacity(0.95),
            AppTheme.colors.surface.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return _buildSetItem(set, index, sets.length);
        }).toList(),
      ),
    );
  }

  /// בניית פריט סט בודד
  Widget _buildSetItem(ExerciseSet set, int index, int totalSets) {
    return Container(
      margin: EdgeInsets.only(bottom: index < totalSets - 1 ? 12 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // אייקון והמספר
            _buildSetIcon(index + 1, set.isPR),
            const SizedBox(width: 12),

            // פרטי הסט
            Expanded(
              child: _buildSetDetails(set),
            ),

            // נפח העבודה
            _buildVolumeChip(set),
          ],
        ),
      ),
    );
  }

  /// בניית אייקון הסט
  Widget _buildSetIcon(int setNumber, bool isPR) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isPR ? Colors.amber : Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isPR ? Colors.amber : Colors.green).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isPR
            ? const Icon(Icons.star, size: 16, color: Colors.white)
            : Text(
                '$setNumber',
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// בניית פרטי הסט
  Widget _buildSetDetails(ExerciseSet set) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // משקל ורפטים
        Row(
          children: [
            if (set.weight != null && set.weight! > 0) ...[
              Icon(
                Icons.fitness_center,
                size: 16,
                color: AppTheme.colors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${set.weight!.toStringAsFixed(set.weight! % 1 == 0 ? 0 : 1)} ק"ג',
                style: GoogleFonts.assistant(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.headline,
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (set.reps != null && set.reps! > 0) ...[
              Icon(
                Icons.repeat,
                size: 16,
                color: AppTheme.colors.accent,
              ),
              const SizedBox(width: 4),
              Text(
                '${set.reps} חזרות',
                style: GoogleFonts.assistant(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.headline,
                ),
              ),
            ],
            if (set.tempo != null) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.timer,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '${set.tempo}s',
                style: GoogleFonts.assistant(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.headline,
                ),
              ),
            ],
          ],
        ),

        // תגיות נוספות (סוג סט, RPE, RIR)
        if (set.setType != SetType.normal ||
            set.rpe != null ||
            set.rir != null) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (set.setType != SetType.normal)
                _buildMiniChip(set.setType.displayName, Colors.purple),
              if (set.rpe != null)
                _buildMiniChip('RPE ${set.rpe}', Colors.orange),
              if (set.rir != null)
                _buildMiniChip('RIR ${set.rir}', Colors.blue),
              if (set.isPR) _buildMiniChip('שיא!', Colors.red),
            ],
          ),
        ],

        // הערות אם יש
        if (set.notes != null && set.notes!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            set.notes!,
            style: GoogleFonts.assistant(
              fontSize: 13,
              color: AppTheme.colors.text.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// בניית תג נפח העבודה
  Widget _buildVolumeChip(ExerciseSet set) {
    final volume = set.volume;

    if (volume <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'נפח',
            style: GoogleFonts.assistant(
              fontSize: 10,
              color: AppTheme.colors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${volume.toStringAsFixed(volume % 1 == 0 ? 0 : 1)}',
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          // הוספת 1RM משוער
          if (set.estimatedOneRepMax != null &&
              set.estimatedOneRepMax! > 0) ...[
            const SizedBox(height: 2),
            Text(
              '1RM: ${set.estimatedOneRepMax!.toStringAsFixed(0)}',
              style: GoogleFonts.assistant(
                fontSize: 9,
                color: AppTheme.colors.primary.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// בניית תג מיני
  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.assistant(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// בניית כפתור "הצג עוד"
  Widget _buildShowMoreButton(int remainingSets) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: onTap,
          icon: Icon(
            Icons.expand_more,
            size: 18,
            color: AppTheme.colors.primary,
          ),
          label: Text(
            'הצג עוד $remainingSets סטים',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: AppTheme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppTheme.colors.primary.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget מותאם לתצוגת סטים ריקה
class EmptyCompletedSets extends StatelessWidget {
  final String exerciseName;

  const EmptyCompletedSets({
    super.key,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: 48,
            color: AppTheme.colors.text.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'טרם הושלמו סטים',
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'התחל את $exerciseName כדי לראות את הסטים שהושלמו כאן',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: AppTheme.colors.text.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget לסטטיסטיקות מהירות
class CompletedSetsStats extends StatelessWidget {
  final List<ExerciseSet> completedSets;
  final String currentExerciseId;

  const CompletedSetsStats({
    super.key,
    required this.completedSets,
    required this.currentExerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final sets = completedSets
        .where((set) => set.exerciseId == currentExerciseId && set.isCompleted)
        .toList();

    if (sets.isEmpty) return const SizedBox.shrink();

    final totalVolume = sets.fold<double>(0, (sum, set) => sum + set.volume);
    final totalReps = sets.fold<int>(0, (sum, set) => sum + (set.reps ?? 0));
    final avgWeight = sets.where((s) => s.weight != null).isNotEmpty
        ? sets
                .where((s) => s.weight != null)
                .map((s) => s.weight!)
                .reduce((a, b) => a + b) /
            sets.where((s) => s.weight != null).length
        : 0.0;
    final maxWeight = sets.where((s) => s.weight != null).isNotEmpty
        ? sets
            .where((s) => s.weight != null)
            .map((s) => s.weight!)
            .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final best1RM = sets.where((s) => s.estimatedOneRepMax != null).isNotEmpty
        ? sets
            .where((s) => s.estimatedOneRepMax != null)
            .map((s) => s.estimatedOneRepMax!)
            .reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.colors.primary.withOpacity(0.1),
            AppTheme.colors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'סטטיסטיקות מפגש',
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildStatItem('נפח כולל', '${totalVolume.toStringAsFixed(0)}',
                  Icons.fitness_center),
              _buildStatItem('סה"כ רפטים', '$totalReps', Icons.repeat),
              _buildStatItem(
                  'משקל ממוצע', '${avgWeight.toStringAsFixed(1)}', Icons.scale),
              _buildStatItem('משקל מקסימלי', '${maxWeight.toStringAsFixed(1)}',
                  Icons.trending_up),
              if (best1RM > 0)
                _buildStatItem('1RM מקסימלי', '${best1RM.toStringAsFixed(0)}',
                    Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppTheme.colors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.text.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
