// lib/widgets/workout/exercise_info.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/exercise.dart';

class ExerciseInfo extends StatefulWidget {
  final Exercise exercise;
  final int currentSet;
  final int totalSets;
  final VoidCallback? onVideoTap;
  final bool showProgress;

  const ExerciseInfo({
    super.key,
    required this.exercise,
    required this.currentSet,
    required this.totalSets,
    this.onVideoTap,
    this.showProgress = true,
  });

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentSet / widget.totalSets,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ExerciseInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.exercise.id != widget.exercise.id) {
      // אתחול מחדש כשמחליפים תרגיל
      _animationController.reset();
    }

    if (oldWidget.currentSet != widget.currentSet) {
      // עדכון אנימציית התקדמות
      _progressAnimation = Tween<double>(
        begin: oldWidget.currentSet / widget.totalSets,
        end: widget.currentSet / widget.totalSets,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// הצגת וידאו במסך מלא
  void _showFullScreenVideo() {
    if (widget.exercise.videoUrl == null || widget.exercise.videoUrl!.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Text(
                'נגן וידאו: ${widget.exercise.videoUrl}',
                style: GoogleFonts.assistant(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// בניית סקציית המדיה (תמונה/וידאו)
  Widget _buildMediaSection() {
    final hasVideo = widget.exercise.videoUrl != null &&
        widget.exercise.videoUrl!.isNotEmpty;
    final hasImage = widget.exercise.displayImage.isNotEmpty;

    if (!hasVideo && !hasImage) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.colors.surface.withOpacity(0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // תמונה או placeholder
            if (hasImage) _buildExerciseImage() else _buildPlaceholderImage(),

            // כפתור וידאו אם יש
            if (hasVideo)
              Positioned.fill(
                child: Semantics(
                  button: true,
                  label: 'נגן וידאו של ${widget.exercise.nameHe}',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onVideoTap ?? _showFullScreenVideo,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // תג וידאו
            if (hasVideo)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'וידאו',
                        style: GoogleFonts.assistant(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// בניית תמונת התרגיל
  Widget _buildExerciseImage() {
    final imageUrl = widget.exercise.displayImage;

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildPlaceholderImage(),
      errorWidget: (context, url, error) => _buildPlaceholderImage(),
    );
  }

  /// בניית תמונת placeholder
  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.colors.primary.withOpacity(0.3),
            AppTheme.colors.accent.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getExerciseIcon(),
            size: 60,
            color: Colors.white54,
          ),
          const SizedBox(height: 8),
          Text(
            widget.exercise.type.hebrewName,
            style: GoogleFonts.assistant(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// קבלת אייקון מתאים לתרגיל
  IconData _getExerciseIcon() {
    return widget.exercise.equipment.icon;
  }

  /// קבלת אמוג'י לשריר
  String _getMuscleEmoji(MuscleGroup muscle) {
    switch (muscle) {
      case MuscleGroup.chest:
        return '🫁';
      case MuscleGroup.back:
        return '🦴';
      case MuscleGroup.shoulders:
        return '🤲';
      case MuscleGroup.biceps:
        return '💪';
      case MuscleGroup.triceps:
        return '🤏';
      case MuscleGroup.forearms:
        return '🤜';
      case MuscleGroup.core:
      case MuscleGroup.abs:
        return '🎯';
      case MuscleGroup.legs:
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
        return '🦵';
      case MuscleGroup.glutes:
        return '🍑';
      case MuscleGroup.calves:
        return '🦶';
      case MuscleGroup.cardio:
        return '❤️';
      case MuscleGroup.lats:
        return '🕊️';
      case MuscleGroup.traps:
        return '🔺';
      default:
        return '💪';
    }
  }

  /// קבלת צבע לשריר
  Color _getMuscleColor(MuscleGroup muscle) {
    return muscle.color;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // סקציית מדיה
          _buildMediaSection(),

          // רווח אם יש מדיה
          if (widget.exercise.videoUrl?.isNotEmpty == true ||
              widget.exercise.displayImage.isNotEmpty)
            const SizedBox(height: 20),

          // שם התרגיל
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.exercise.nameHe,
                  style: GoogleFonts.assistant(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colors.headline,
                  ),
                ),
              ),
              if (widget.exercise.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'מאומת',
                        style: GoogleFonts.assistant(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // תיאור התרגיל
          if (widget.exercise.descriptionHe.isNotEmpty) ...[
            Text(
              widget.exercise.descriptionHe,
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: colors.text.withOpacity(0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // הוראות ביצוע
          if (widget.exercise.instructionsHe.isNotEmpty) ...[
            Text(
              'הוראות ביצוע:',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.headline,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.exercise.instructionsHe.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: GoogleFonts.assistant(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: GoogleFonts.assistant(
                          fontSize: 15,
                          color: colors.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],

          // תגיות מידע
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // שריר ראשי
              if (widget.exercise.primaryMuscles.isNotEmpty)
                _buildInfoChip(
                  icon: Icons.fitness_center,
                  label: widget.exercise.primaryMuscles.first.hebrewName,
                  emoji: _getMuscleEmoji(widget.exercise.primaryMuscles.first),
                  backgroundColor:
                      _getMuscleColor(widget.exercise.primaryMuscles.first),
                ),

              // התקדמות סטים
              _buildInfoChip(
                icon: Icons.repeat,
                label: '${widget.currentSet}/${widget.totalSets} סטים',
                backgroundColor: colors.accent,
              ),

              // ציוד
              _buildInfoChip(
                icon: widget.exercise.equipment.icon,
                label: widget.exercise.equipment.hebrewName,
                backgroundColor: colors.primary,
              ),

              // רמת קושי
              _buildInfoChip(
                icon: widget.exercise.difficulty.icon,
                label: widget.exercise.difficulty.hebrewName,
                backgroundColor: widget.exercise.difficulty.color,
              ),
            ],
          ),

          // התקדמות סטים
          if (widget.showProgress && widget.totalSets > 1) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'התקדמות:',
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    label: 'התקדמות סטים',
                    value: 'סט ${widget.currentSet} מתוך ${widget.totalSets}',
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: colors.surface,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(colors.primary),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${((widget.currentSet / widget.totalSets) * 100).toInt()}%',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],

          // שרירים משניים
          if (widget.exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'שרירים משניים:',
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.headline,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.exercise.secondaryMuscles.map((muscle) {
                return _buildInfoChip(
                  icon: Icons.fitness_center,
                  label: muscle.hebrewName,
                  emoji: _getMuscleEmoji(muscle),
                  backgroundColor: _getMuscleColor(muscle).withOpacity(0.6),
                  isSmall: true,
                );
              }).toList(),
            ),
          ],

          // דירוג
          if (widget.exercise.rating > 0) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'דירוג:',
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(5, (index) {
                  return Icon(
                    index < widget.exercise.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 20,
                    color: Colors.amber,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '(${widget.exercise.ratingCount} ביקורות)',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// בניית תג מידע
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    String? emoji,
    Color? backgroundColor,
    bool isSmall = false,
  }) {
    final colors = AppTheme.colors;

    return Tooltip(
      message: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 14,
          vertical: isSmall ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: (backgroundColor ?? colors.primary).withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: (backgroundColor ?? colors.primary).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(
                emoji,
                style: TextStyle(fontSize: isSmall ? 14 : 16),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              icon,
              size: isSmall ? 16 : 18,
              color: backgroundColor ?? colors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.assistant(
                fontSize: isSmall ? 13 : 15,
                color: colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
