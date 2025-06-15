import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise.dart';

class ExerciseInfo extends StatefulWidget {
  final Exercise exercise;
  final int currentSet;
  final int totalSets;

  const ExerciseInfo({
    super.key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
  });

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ExerciseInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.id != widget.exercise.id) {
      // Stop video when changing exercises
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showFullScreenVideo() {
    // Implementation of _showFullScreenVideo method
  }

  Widget _buildMediaSection() {
    // Implementation of _buildMediaSection method
    return const SizedBox.shrink();
  }

  String _getMuscleEmoji(String muscle) {
    // Implementation of _getMuscleEmoji method
    return '💪';
  }

  Color _getMuscleColor(String muscle) {
    // Implementation of _getMuscleColor method
    return AppTheme.colors.primary.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMediaSection(),
          if (widget.exercise.videoUrl != null &&
                  widget.exercise.videoUrl!.isNotEmpty ||
              widget.exercise.imageUrl != null &&
                  widget.exercise.imageUrl!.isNotEmpty)
            const SizedBox(height: 16),
          Text(
            widget.exercise.nameHe,
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercise.instructionsHe.join('\n'),
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (widget.exercise.mainMuscles?.isNotEmpty == true)
                _buildInfoChip(
                  icon: Icons.fitness_center,
                  label: widget.exercise.mainMuscles!.first,
                  emoji: _getMuscleEmoji(widget.exercise.mainMuscles!.first),
                  backgroundColor:
                      _getMuscleColor(widget.exercise.mainMuscles!.first),
                ),
              _buildInfoChip(
                icon: Icons.repeat,
                label: '${widget.currentSet}/${widget.totalSets} סטים',
              ),
              if (widget.exercise.equipment?.isNotEmpty == true)
                _buildInfoChip(
                  icon: Icons.sports_gymnastics,
                  label: widget.exercise.equipment!,
                ),
            ],
          ),
          if (widget.totalSets > 1) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: widget.currentSet / widget.totalSets,
              backgroundColor: Colors.white12,
              color: AppTheme.colors.primary,
              minHeight: 4,
            ),
          ],
          if (widget.exercise.secondaryMuscles?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Text(
              'שרירים משניים:',
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.exercise.secondaryMuscles?.map((muscle) {
                    return _buildInfoChip(
                      icon: Icons.fitness_center,
                      label: muscle,
                      emoji: _getMuscleEmoji(muscle),
                      backgroundColor: _getMuscleColor(muscle).withOpacity(0.1),
                      isSmall: true,
                    );
                  }).toList() ??
                  [],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    String? emoji,
    Color? backgroundColor,
    bool isSmall = false,
  }) {
    return Tooltip(
      message: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.colors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: TextStyle(fontSize: isSmall ? 12 : 15)),
              const SizedBox(width: 3),
            ],
            Icon(
              icon,
              size: isSmall ? 14 : 16,
              color: AppTheme.colors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.assistant(
                fontSize: isSmall ? 12 : 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
