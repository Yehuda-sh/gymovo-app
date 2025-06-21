// lib/features/workouts/screens/workout_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/workout_model.dart';
import 'workout_mode/workout_mode_screen.dart';
import '../providers/workouts_provider.dart';
import 'package:provider/provider.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailsScreen> createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    // TODO: טען את הסטטוס מהמועדפים (SharedPreferences / Database)
    setState(() {
      _isFavorite = false; // ברירת מחדל
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildWorkoutStats()),
            SliverToBoxAdapter(child: _buildExercisesList()),
            const SliverToBoxAdapter(
                child: SizedBox(height: 100)), // רווח תחתון לכפתור
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    final colors = AppTheme.colors;

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.workout.title,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                colors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            _buildPopupMenuItem('edit', Icons.edit, 'ערוך אימון'),
            _buildPopupMenuItem('duplicate', Icons.copy, 'שכפל אימון'),
            _buildPopupMenuItem('share', Icons.share, 'שתף אימון'),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('מחק אימון',
                      style: GoogleFonts.assistant(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
      String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.assistant()),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
    final colors = AppTheme.colors;
    final totalVolume = _calculateTotalVolume();
    final estimatedTime = _calculateEstimatedTime();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.workout.description != null &&
              widget.workout.description!.isNotEmpty) ...[
            Text(
              'תיאור האימון',
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.headline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.workout.description!,
              style: GoogleFonts.assistant(
                fontSize: 14,
                color: colors.headline.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            'סטטיסטיקות האימון',
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.fitness_center,
                  title: 'תרגילים',
                  value: '${widget.workout.exercises.length}',
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.timer,
                  title: 'זמן משוער',
                  value: '${estimatedTime} דק׳',
                  color: colors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.line_weight,
                  title: 'נפח כולל',
                  value: '${totalVolume.toStringAsFixed(1)} ק"ג',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'נוצר ב',
                  value: _formatDate(widget.workout.createdAt),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.headline.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    final colors = AppTheme.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'תרגילי האימון',
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.workout.exercises.length,
            itemBuilder: (context, index) {
              final exercise = widget.workout.exercises[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 100)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.assistant(
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: GoogleFonts.assistant(
                          fontWeight: FontWeight.bold,
                          color: colors.headline,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.fitness_center,
                                size: 14, color: colors.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${exercise.sets.length} סטים',
                              style: GoogleFonts.assistant(
                                color: colors.headline.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            if (exercise.restTime != null) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.timer, size: 14, color: colors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '${exercise.restTime} שניות מנוחה',
                                style: GoogleFonts.assistant(
                                  color: colors.headline.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (exercise.notes != null &&
                                  exercise.notes!.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.note,
                                              size: 16, color: colors.accent),
                                          const SizedBox(width: 6),
                                          Text(
                                            'הערות',
                                            style: GoogleFonts.assistant(
                                              fontWeight: FontWeight.bold,
                                              color: colors.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        exercise.notes!,
                                        style: GoogleFonts.assistant(
                                          color:
                                              colors.headline.withOpacity(0.8),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              _buildSetsTable(exercise),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSetsTable(ExerciseModel exercise) {
    final colors = AppTheme.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: _buildTableHeader('סט')),
                Expanded(flex: 2, child: _buildTableHeader('חזרות')),
                Expanded(flex: 2, child: _buildTableHeader('משקל')),
                Expanded(flex: 2, child: _buildTableHeader('מנוחה')),
              ],
            ),
          ),
          ...exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;
            final isEven = index % 2 == 0;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    isEven ? colors.surface : colors.primary.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: _buildTableCell('${index + 1}')),
                  Expanded(
                      flex: 2,
                      child: _buildTableCell(set.reps?.toString() ?? '-')),
                  Expanded(
                    flex: 2,
                    child: _buildTableCell(
                      set.weight != null
                          ? '${set.weight!.toStringAsFixed(1)} ק"ג'
                          : '-',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildTableCell(
                        set.restTime != null ? '${set.restTime} שנ' : '-'),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) => Text(
        text,
        style: GoogleFonts.assistant(
          fontWeight: FontWeight.bold,
          color: AppTheme.colors.primary,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      );

  Widget _buildTableCell(String text) => Text(
        text,
        style: GoogleFonts.assistant(
          color: AppTheme.colors.headline,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      );

  Widget _buildBottomBar() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previewWorkout,
                icon: const Icon(Icons.preview),
                label: Text(
                  'תצוגה מקדימה',
                  style: GoogleFonts.assistant(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: colors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _startWorkout,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isLoading ? 'טוען...' : 'התחל אימון',
                  style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // חישובי עזר

  double _calculateTotalVolume() {
    double total = 0;
    for (final exercise in widget.workout.exercises) {
      for (final set in exercise.sets) {
        if (set.weight != null && set.reps != null) {
          total += set.weight! * set.reps!;
        }
      }
    }
    return total;
  }

  int _calculateEstimatedTime() {
    int totalTime = 0;
    for (final exercise in widget.workout.exercises) {
      totalTime += exercise.sets.length * 30; // זמן ביצוע משוער לסט

      // זמן מנוחה בין הסטים
      if (exercise.restTime != null) {
        totalTime += exercise.sets.length * exercise.restTime!;
      } else {
        totalTime += exercise.sets.length * 60; // ברירת מחדל: 60 שניות מנוחה
      }
    }
    return totalTime ~/ 60; // המרה לדקות
  }

  void _toggleFavorite() {
    HapticFeedback.lightImpact();
    setState(() => _isFavorite = !_isFavorite);

    // TODO: שמור את הסטטוס במאגר/SharedPreferences

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'נוסף למועדפים' : 'הוסר מהמועדפים',
          style: GoogleFonts.assistant(),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'edit':
        _editWorkout();
        break;
      case 'duplicate':
        _duplicateWorkout();
        break;
      case 'share':
        _shareWorkout();
        break;
      case 'delete':
        _deleteWorkout();
        break;
    }
  }

  void _editWorkout() {
    Navigator.pushNamed(context, '/edit-workout', arguments: widget.workout);
  }

  void _duplicateWorkout() {
    // TODO: הוסף לוגיקה לשכפול אימון
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'האימון שוכפל בהצלחה',
          style: GoogleFonts.assistant(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareWorkout() {
    // TODO: הוסף לוגיקה לשיתוף אימון
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'האימון הועבר לשיתוף',
          style: GoogleFonts.assistant(),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'מחיקת אימון',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'האם אתה בטוח שברצונך למחוק את האימון "${widget.workout.title}"?',
          style: GoogleFonts.assistant(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ביטול', style: GoogleFonts.assistant()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // TODO: הוסף לוגיקה למחיקת האימון מהמאגר
            },
            child: Text('מחק', style: GoogleFonts.assistant(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _previewWorkout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'תצוגה מקדימה',
                  style: GoogleFonts.assistant(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.workout.exercises[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(exercise.name,
                          style: GoogleFonts.assistant(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text('${exercise.sets.length} סטים',
                          style: GoogleFonts.assistant()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startWorkout() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<WorkoutsProvider>();
      final exerciseDetails = await provider.getExerciseDetails(widget.workout);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutModeScreen(
            workout: widget.workout,
            exerciseDetailsMap: exerciseDetails,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('שגיאה בטעינת האימון: $e', style: GoogleFonts.assistant()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'ינואר',
      'פברואר',
      'מרץ',
      'אפריל',
      'מאי',
      'יוני',
      'יולי',
      'אוגוסט',
      'ספטמבר',
      'אוקטובר',
      'נובמבר',
      'דצמבר',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
