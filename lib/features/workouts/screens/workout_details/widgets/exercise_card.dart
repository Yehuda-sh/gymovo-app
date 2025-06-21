// lib/features/workouts/screens/workout_details/widgets/exercise_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../../../../../models/workout_model.dart';
import 'sets_table.dart';

class ExerciseCard extends StatefulWidget {
  final ExerciseModel exercise;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isInWorkoutMode;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.isExpanded = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.isInWorkoutMode = false,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
    widget.onTap?.call();
  }

  String _formatRestTime(int? restTimeSeconds) {
    if (restTimeSeconds == null || restTimeSeconds == 0) return 'ללא מנוחה';

    if (restTimeSeconds < 60) {
      return '$restTimeSeconds שניות';
    } else {
      final minutes = restTimeSeconds ~/ 60;
      final seconds = restTimeSeconds % 60;
      if (seconds == 0) {
        return '$minutes דקות';
      } else {
        return '$minutes:${seconds.toString().padLeft(2, '0')} דקות';
      }
    }
  }

  Color _getExerciseColor() {
    final colors = AppTheme.colors;

    // צבע לפי סוג התרגיל (ניתן להתאים לפי הצורך)
    final exerciseName = widget.exercise.name.toLowerCase();

    if (exerciseName.contains('חזה') || exerciseName.contains('דחיפ')) {
      return Colors.blue;
    } else if (exerciseName.contains('גב') || exerciseName.contains('משיכ')) {
      return Colors.green;
    } else if (exerciseName.contains('רגל') ||
        exerciseName.contains('סקוואט')) {
      return Colors.orange;
    } else if (exerciseName.contains('זרוע') || exerciseName.contains('כתף')) {
      return Colors.purple;
    } else {
      return colors.primary;
    }
  }

  Widget _buildExerciseIcon() {
    final exerciseName = widget.exercise.name.toLowerCase();
    IconData icon;

    if (exerciseName.contains('חזה') || exerciseName.contains('דחיפ')) {
      icon = Icons.fitness_center;
    } else if (exerciseName.contains('גב') || exerciseName.contains('משיכ')) {
      icon = Icons.rowing;
    } else if (exerciseName.contains('רגל') ||
        exerciseName.contains('סקוואט')) {
      icon = Icons.directions_run;
    } else if (exerciseName.contains('כרדיו') || exerciseName.contains('ריצ')) {
      icon = Icons.favorite;
    } else {
      icon = Icons.sports_gymnastics;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getExerciseColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: _getExerciseColor(),
        size: 20,
      ),
    );
  }

  Widget _buildStatsChips() {
    final colors = AppTheme.colors;
    final totalWeight = widget.exercise.sets.fold<double>(
      0,
      (sum, set) => sum + ((set.weight ?? 0) * (set.reps ?? 0)),
    );
    final totalReps = widget.exercise.sets.fold<int>(
      0,
      (sum, set) => sum + (set.reps ?? 0),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildStatChip(
          '${widget.exercise.sets.length} סטים',
          Icons.format_list_numbered,
          colors.primary,
        ),
        if (totalReps > 0)
          _buildStatChip(
            '$totalReps חזרות',
            Icons.repeat,
            Colors.blue,
          ),
        if (totalWeight > 0)
          _buildStatChip(
            '${totalWeight.toStringAsFixed(0)} ק"ג',
            Icons.monitor_weight,
            Colors.green,
          ),
      ],
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final colors = AppTheme.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onEdit != null)
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 20),
            onPressed: widget.onEdit,
            tooltip: 'עריכה',
            color: colors.primary,
          ),
        if (widget.onDelete != null)
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20),
            onPressed: widget.onDelete,
            tooltip: 'מחיקה',
            color: colors.error,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: _isExpanded ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _isExpanded
            ? BorderSide(color: _getExerciseColor().withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          // כותרת התרגיל
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildExerciseIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.name,
                          style: GoogleFonts.assistant(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colors.headline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatsChips(),
                      ],
                    ),
                  ),
                  if (widget.showActions) _buildActionButtons(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // תוכן מורחב
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // הערות התרגיל
                          if (widget.exercise.notes?.isNotEmpty == true) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colors.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.note_outlined,
                                        size: 16,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'הערות:',
                                        style: GoogleFonts.assistant(
                                          fontWeight: FontWeight.w600,
                                          color: colors.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.exercise.notes!,
                                    style: GoogleFonts.assistant(
                                      color: colors.text,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // טבלת סטים
                          SetsTable(exercise: widget.exercise),

                          // מידע נוסף
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // זמן מנוחה
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _formatRestTime(
                                              widget.exercise.restTime),
                                          style: GoogleFonts.assistant(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // מידע נוסף (במקום רמת קושי שלא קיימת)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 16,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${widget.exercise.sets.length} סטים',
                                          style: GoogleFonts.assistant(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // הסרת הפונקציה _getDifficultyColor כי אין שדה difficulty
}
