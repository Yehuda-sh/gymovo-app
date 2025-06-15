import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/exercise_history.dart';
import '../../../theme/app_theme.dart';

class ExerciseSetList extends StatefulWidget {
  final List<ExerciseSet> sets;
  final Function(ExerciseSet) onEdit;
  final Function(String) onDelete;
  final bool showDate;
  final bool groupByDate;

  const ExerciseSetList({
    Key? key,
    required this.sets,
    required this.onEdit,
    required this.onDelete,
    this.showDate = true,
    this.groupByDate = false,
  }) : super(key: key);

  @override
  State<ExerciseSetList> createState() => _ExerciseSetListState();
}

class _ExerciseSetListState extends State<ExerciseSetList> {
  String? _selectedFilter = 'all';

  List<ExerciseSet> get _filteredSets {
    switch (_selectedFilter) {
      case 'completed':
        return widget.sets.where((set) => set.isCompleted).toList();
      case 'incomplete':
        return widget.sets.where((set) => !set.isCompleted).toList();
      case 'recent':
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        return widget.sets.where((set) => set.date.isAfter(weekAgo)).toList();
      default:
        return widget.sets;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sets.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (widget.sets.length > 3) _buildFilterChips(),
        Expanded(child: _buildSetsList()),
      ],
    );
  }

  Widget _buildEmptyState() {
    final colors = AppTheme.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 80,
            color: colors.text.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'אין סטים להצגה',
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'התחל להוסיף סטים כדי לעקוב אחר ההתקדמות שלך',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: colors.text.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'הכל', Icons.list),
            const SizedBox(width: 8),
            _buildFilterChip('completed', 'הושלמו', Icons.check_circle),
            const SizedBox(width: 8),
            _buildFilterChip(
                'incomplete', 'לא הושלמו', Icons.radio_button_unchecked),
            const SizedBox(width: 8),
            _buildFilterChip('recent', 'השבוע', Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    final colors = AppTheme.colors;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
        HapticFeedback.selectionClick();
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : colors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : colors.primary,
            ),
          ),
        ],
      ),
      backgroundColor: colors.surface,
      selectedColor: colors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? colors.primary : colors.primary.withOpacity(0.3),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildSetsList() {
    final sets = _filteredSets;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return _buildSetCard(set, index);
      },
    );
  }

  Widget _buildSetCard(ExerciseSet set, int index) {
    final colors = AppTheme.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(set.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        confirmDismiss: (direction) => _showDeleteConfirmation(set),
        onDismissed: (_) {
          HapticFeedback.mediumImpact();
          widget.onDelete(set.id);
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: set.isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : colors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onEdit(set);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSetHeader(set, index),
                  const SizedBox(height: 12),
                  _buildSetDetails(set),
                  if (set.notes?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 12),
                    _buildSetNotes(set.notes!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetHeader(ExerciseSet set, int index) {
    final colors = AppTheme.colors;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: set.isCompleted
                ? Colors.green
                : colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: set.isCompleted
                ? null
                : Border.all(color: colors.primary.withOpacity(0.3)),
          ),
          child: Center(
            child: set.isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    '${index + 1}',
                    style: GoogleFonts.assistant(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${set.weight?.toInt() ?? 0} ק"ג × ${set.reps ?? 0} חזרות',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
              if (widget.showDate && !widget.groupByDate)
                Text(
                  _formatDate(set.date),
                  style: GoogleFonts.assistant(
                    fontSize: 13,
                    color: colors.text.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
        if (!set.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Text(
              'לא הושלם',
              style: GoogleFonts.assistant(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSetDetails(ExerciseSet set) {
    final colors = AppTheme.colors;

    return Row(
      children: [
        _buildDetailChip(
          Icons.fitness_center,
          '${set.weight?.toInt() ?? 0} ק"ג',
          Colors.blue,
        ),
        const SizedBox(width: 8),
        _buildDetailChip(
          Icons.repeat,
          '${set.reps ?? 0} חזרות',
          Colors.green,
        ),
        if (set.restTime != null && set.restTime! > 0) ...[
          const SizedBox(width: 8),
          _buildDetailChip(
            Icons.timer,
            '${set.restTime}״',
            Colors.orange,
          ),
        ],
        const Spacer(),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            widget.onEdit(set);
          },
          icon: const Icon(Icons.edit_outlined),
          iconSize: 20,
          color: colors.primary,
          tooltip: 'ערוך סט',
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
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

  Widget _buildSetNotes(String notes) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 16,
            color: colors.text.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notes,
              style: GoogleFonts.assistant(
                fontSize: 14,
                color: colors.text.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            'מחק',
            style: GoogleFonts.assistant(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(ExerciseSet set) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'מחיקת סט',
            style: GoogleFonts.assistant(
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'האם אתה בטוח שברצונך למחוק את הסט הזה?',
                style: GoogleFonts.assistant(
                  color: AppTheme.colors.text,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.colors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 16,
                      color: AppTheme.colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${set.weight?.toInt() ?? 0} ק"ג × ${set.reps ?? 0} חזרות',
                      style: GoogleFonts.assistant(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'פעולה זו לא ניתנת לביטול.',
                style: GoogleFonts.assistant(
                  fontSize: 13,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'ביטול',
                style: GoogleFonts.assistant(
                  color: AppTheme.colors.text.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'מחק',
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'היום ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'אתמול ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return 'לפני ${difference.inDays} ימים';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
