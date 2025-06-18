// lib/widgets/exercise_card.dart
// --------------------------------------------------
// כרטיס תרגיל מתקדם ויפה
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exercise.dart';

class ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onAddToWorkout;
  final bool isFavorite;
  final bool showActions;
  final EdgeInsetsGeometry? margin;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onFavorite,
    this.onAddToWorkout,
    this.isFavorite = false,
    this.showActions = true,
    this.margin,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  String _getDifficultyDisplayName(String? difficulty) {
    if (difficulty == null) return 'בינוני';

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'מתחילים';
      case 'easy':
        return 'קל';
      case 'medium':
        return 'בינוני';
      case 'hard':
        return 'קשה';
      case 'advanced':
        return 'מתקדם';
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String? difficulty, ColorScheme colorScheme) {
    if (difficulty == null) return colorScheme.primary;

    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'easy':
        return Colors.lightGreen;
      case 'medium':
        return colorScheme.primary;
      case 'hard':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }

  String _getEquipmentDisplayName(String? equipment) {
    if (equipment == null) return '';

    const equipmentMap = {
      'bodyweight': 'משקל גוף',
      'dumbbell': 'דמבל',
      'barbell': 'מוט',
      'kettlebell': 'כדור משקולות',
      'machine': 'מכונה',
      'cable': 'כבל',
      'resistanceBand': 'רצועת התנגדות',
      'trx': 'רצועות TRX',
      'mat': 'מזרן אימון',
      'abWheel': 'גלגל בטן',
      'pullupBar': 'מוט מתח',
      'pushupBars': 'פומית שכיבות שמיכה',
      'other': 'אחר',
    };

    return equipmentMap[equipment.toLowerCase()] ?? equipment;
  }

  Widget _buildMuscleChips() {
    final muscles = <String>[];

    if (widget.exercise.mainMuscles?.isNotEmpty == true) {
      muscles.addAll(widget.exercise.mainMuscles!.take(2));
    } else if (widget.exercise.muscleGroups?.isNotEmpty == true) {
      muscles.addAll(widget.exercise.muscleGroups!.take(2));
    }

    if (muscles.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: muscles.map((muscle) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            muscle,
            style: GoogleFonts.assistant(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: widget.margin ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: widget.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _isPressed
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.shadow.withOpacity(0.1),
                        blurRadius: _isPressed ? 12 : 8,
                        offset: Offset(0, _isPressed ? 4 : 2),
                        spreadRadius: _isPressed ? 2 : 0,
                      ),
                    ],
                    border: Border.all(
                      color: _isPressed
                          ? colorScheme.primary.withOpacity(0.5)
                          : colorScheme.outline.withOpacity(0.2),
                      width: _isPressed ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // תמונה או פלייסהולדר
                        Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primaryContainer.withOpacity(0.8),
                                colorScheme.secondaryContainer.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // תמונת רקע או אייקון
                              if (widget.exercise.imageUrl != null &&
                                  widget.exercise.imageUrl!.isNotEmpty)
                                Positioned.fill(
                                  child: Image.network(
                                    widget.exercise.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage();
                                    },
                                  ),
                                )
                              else
                                _buildPlaceholderImage(),

                              // גרדיאנט עליון לטקסט
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // כפתורי פעולה
                              if (widget.showActions)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (widget.onFavorite != null)
                                        _buildActionButton(
                                          icon: widget.isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          onPressed: widget.onFavorite!,
                                          color: widget.isFavorite
                                              ? Colors.red
                                              : Colors.white,
                                        ),
                                      if (widget.onAddToWorkout != null) ...[
                                        const SizedBox(width: 8),
                                        _buildActionButton(
                                          icon: Icons.add_circle_outline,
                                          onPressed: widget.onAddToWorkout!,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                              // תגית רמת קושי
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(
                                        widget.exercise.difficulty,
                                        colorScheme),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getDifficultyDisplayName(
                                        widget.exercise.difficulty),
                                    style: GoogleFonts.assistant(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              // אייקון וידאו אם קיים
                              if (widget.exercise.videoUrl != null &&
                                  widget.exercise.videoUrl!.isNotEmpty)
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // תוכן הכרטיס
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // שם התרגיל
                              Text(
                                widget.exercise.nameHe,
                                style: GoogleFonts.assistant(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              if (widget.exercise.nameHe !=
                                  widget.exercise.name) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.exercise.name,
                                  style: GoogleFonts.assistant(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

                              const SizedBox(height: 8),

                              // תיאור קצר
                              if (widget.exercise.descriptionHe != null &&
                                  widget.exercise.descriptionHe!.isNotEmpty)
                                Text(
                                  widget.exercise.descriptionHe!,
                                  style: GoogleFonts.assistant(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              const SizedBox(height: 12),

                              // תגיות שרירים
                              _buildMuscleChips(),

                              const SizedBox(height: 12),

                              // שורה תחתונה - ציוד וקטגוריה
                              Row(
                                children: [
                                  if (widget.exercise.equipment != null &&
                                      widget
                                          .exercise.equipment!.isNotEmpty) ...[
                                    Icon(
                                      _getEquipmentIcon(
                                          widget.exercise.equipment),
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getEquipmentDisplayName(
                                          widget.exercise.equipment),
                                      style: GoogleFonts.assistant(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (widget.exercise.category != null &&
                                      widget.exercise.category!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.tertiaryContainer
                                            .withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.exercise.category!,
                                        style: GoogleFonts.assistant(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              colorScheme.onTertiaryContainer,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(widget.exercise.category),
          size: 48,
          color:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.fitness_center;

    switch (category.toLowerCase()) {
      case 'strength':
      case 'כוח':
        return Icons.fitness_center;
      case 'cardio':
      case 'קרדיו':
        return Icons.directions_run;
      case 'flexibility':
      case 'גמישות':
        return Icons.accessibility_new;
      case 'balance':
      case 'איזון':
        return Icons.balance;
      case 'core':
      case 'ליבה':
        return Icons.center_focus_strong;
      case 'legs':
      case 'רגליים':
        return Icons.airline_seat_legroom_extra;
      case 'arms':
      case 'זרועות':
        return Icons.back_hand;
      case 'chest':
      case 'חזה':
        return Icons.accessibility;
      case 'back':
      case 'גב':
        return Icons.accessibility_new;
      case 'shoulders':
      case 'כתפיים':
        return Icons.accessibility;
      default:
        return Icons.fitness_center;
    }
  }

  IconData _getEquipmentIcon(String? equipment) {
    if (equipment == null) return Icons.fitness_center;

    switch (equipment.toLowerCase()) {
      case 'bodyweight':
        return Icons.accessibility_new;
      case 'dumbbell':
        return Icons.fitness_center;
      case 'barbell':
        return Icons.fitness_center;
      case 'kettlebell':
        return Icons.sports_gymnastics;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'cable':
        return Icons.cable;
      case 'resistanceband':
        return Icons.linear_scale;
      case 'trx':
        return Icons.sports_gymnastics;
      case 'mat':
        return Icons.sports_kabaddi;
      case 'abwheel':
        return Icons.album;
      case 'pullupbar':
        return Icons.horizontal_rule;
      case 'pushupbars':
        return Icons.unfold_more;
      default:
        return Icons.fitness_center;
    }
  }
}

// Widget עזר לכרטיס תרגיל קומפקטי
class CompactExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final bool isSelected;

  const CompactExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: isSelected ? 8 : 2,
        color: isSelected ? colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // אייקון או תמונה קטנה
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                exercise.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.fitness_center,
                                    color: colorScheme.onSecondaryContainer,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.fitness_center,
                              color: colorScheme.onSecondaryContainer,
                            ),
                ),

                const SizedBox(width: 12),

                // פרטי התרגיל
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.nameHe,
                        style: GoogleFonts.assistant(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (exercise.mainMuscles?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercise.mainMuscles!.take(2).join(', '),
                          style: GoogleFonts.assistant(
                            fontSize: 12,
                            color: isSelected
                                ? colorScheme.onPrimaryContainer
                                    .withOpacity(0.8)
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // רמת קושי
                if (exercise.difficulty != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                          exercise.difficulty!, colorScheme),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getDifficultyDisplayName(exercise.difficulty!),
                      style: GoogleFonts.assistant(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficultyDisplayName(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'מתחילים';
      case 'easy':
        return 'קל';
      case 'medium':
        return 'בינוני';
      case 'hard':
        return 'קשה';
      case 'advanced':
        return 'מתקדם';
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty, ColorScheme colorScheme) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'easy':
        return Colors.lightGreen;
      case 'medium':
        return colorScheme.primary;
      case 'hard':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return colorScheme.primary;
    }
  }
}
