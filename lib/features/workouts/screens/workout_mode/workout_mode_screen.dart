// lib/features/workouts/screens/workout_mode/workout_mode_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../models/workout_model.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/exercise.dart' as ExerciseLib;
import '../../providers/workout_mode_provider.dart';

// Widgets imports
import 'widgets/set_row.dart';
import 'widgets/exercise_progress_bar.dart';
import 'widgets/workout_complete.dart';
import 'dialogs/edit_rest_dialog.dart';
import 'dialogs/edit_set_dialog.dart';
import 'dialogs/exercise_quick_view.dart';
import 'widgets/top_bar.dart';

class WorkoutModeScreen extends StatelessWidget {
  final WorkoutModel workout;
  final Map<String, ExerciseLib.Exercise> exerciseDetailsMap;

  const WorkoutModeScreen({
    super.key,
    required this.workout,
    required this.exerciseDetailsMap,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutModeProvider(
        workout: workout,
        exerciseDetailsMap: exerciseDetailsMap,
      ),
      child: const _WorkoutModeView(),
    );
  }
}

class _WorkoutModeView extends StatefulWidget {
  const _WorkoutModeView();

  @override
  State<_WorkoutModeView> createState() => _WorkoutModeViewState();
}

class _WorkoutModeViewState extends State<_WorkoutModeView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Timer? _restTimer;
  Timer? _elapsedTimer;
  bool _isInBackground = false;
  int _currentRestSeconds = 0;
  Duration _elapsedTime = Duration.zero;
  DateTime? _workoutStartTime;

  late AnimationController _restAnimationController;
  late Animation<double> _restAnimation;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _startWorkout();
  }

  void _setupAnimations() {
    _restAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _restAnimation = CurvedAnimation(
      parent: _restAnimationController,
      curve: Curves.easeInOut,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    );
  }

  void _startWorkout() {
    _workoutStartTime = DateTime.now();
    _startElapsedTimer();
    final provider = context.read<WorkoutModeProvider>();
    if (provider.status == WorkoutStatus.notStarted) {
      provider.startWorkout();
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _workoutStartTime == null) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedTime = DateTime.now().difference(_workoutStartTime!);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restTimer?.cancel();
    _elapsedTimer?.cancel();
    _restAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<WorkoutModeProvider>();

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (provider.status == WorkoutStatus.active) {
          _pauseWorkout();
          _isInBackground = true;
        }
        break;
      case AppLifecycleState.resumed:
        if (_isInBackground) {
          _showResumeDialog();
        }
        _isInBackground = false;
        break;
      default:
        break;
    }
  }

  void _pauseWorkout() {
    final provider = context.read<WorkoutModeProvider>();
    provider.pauseWorkout();
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
  }

  void _resumeWorkout() {
    final provider = context.read<WorkoutModeProvider>();
    provider.resumeWorkout();
    _startElapsedTimer();
    if (_currentRestSeconds > 0) {
      _startRestTimer(_currentRestSeconds);
    }
  }

  void _showResumeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.pause_circle_outline,
                color: AppTheme.colors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              'האימון הושהה',
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'האימון הושהה אוטומטית כשהאפליקציה עברה לרקע.\nהאם תרצה להמשיך?',
          style: GoogleFonts.assistant(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finishWorkout();
            },
            child: Text(
              'סיום אימון',
              style: GoogleFonts.assistant(color: AppTheme.colors.error),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeWorkout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'המשך',
              style: GoogleFonts.assistant(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startRestTimer(int seconds) {
    _currentRestSeconds = seconds;
    _restAnimationController.forward();

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentRestSeconds--;
      });

      if (_currentRestSeconds <= 0) {
        timer.cancel();
        _restTimer = null;
        _restAnimationController.reverse();
        _showRestCompleteNotification();
      } else if (_currentRestSeconds <= 3) {
        HapticFeedback.selectionClick();
      }
    });
  }

  void _showRestCompleteNotification() {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'זמן המנוחה הסתיים!',
                    style: GoogleFonts.assistant(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'מוכן לסט הבא?',
                    style: GoogleFonts.assistant(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.colors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'בסדר',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final provider = context.read<WorkoutModeProvider>();

    if (provider.status == WorkoutStatus.completed) {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.exit_to_app, color: AppTheme.colors.error, size: 28),
                const SizedBox(width: 12),
                Text(
                  'יציאה מהאימון',
                  style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'האם אתה בטוח שתרצה לצאת מהאימון?',
                  style: GoogleFonts.assistant(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'ההתקדמות שלך תישמר.',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: AppTheme.colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'ביטול',
                  style: GoogleFonts.assistant(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _finishWorkout();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'יציאה',
                  style: GoogleFonts.assistant(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _finishWorkout() {
    final provider = context.read<WorkoutModeProvider>();
    provider.completeWorkout();
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<WorkoutModeProvider>(
        builder: (context, provider, _) {
          final colors = AppTheme.colors;

          return Scaffold(
            backgroundColor: colors.background,
            appBar: _buildAppBar(provider, colors),
            body: provider.status == WorkoutStatus.completed
                ? WorkoutCompleteWidget()
                : Column(
                    children: [
                      _buildWorkoutHeader(provider),

                      // אינדיקטור מנוחה גלובלי
                      AnimatedBuilder(
                        animation: _restAnimation,
                        builder: (context, child) {
                          return _currentRestSeconds > 0
                              ? SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    end: Offset.zero,
                                  ).animate(_restAnimation),
                                  child: _buildRestIndicator(),
                                )
                              : const SizedBox.shrink();
                        },
                      ),

                      Expanded(
                        child: _buildExercisesList(provider),
                      ),
                    ],
                  ),
            floatingActionButton: _buildFloatingActionButton(provider),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(WorkoutModeProvider provider, colors) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.workout.title,
            style: GoogleFonts.assistant(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _formatElapsedTime(_elapsedTime),
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      actions: [
        // אחוז התקדמות
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: provider.status == WorkoutStatus.completed
                  ? LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.2),
                        Colors.green.withOpacity(0.3)
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        colors.primary.withOpacity(0.2),
                        colors.primary.withOpacity(0.3)
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.status == WorkoutStatus.completed
                    ? Colors.green.withOpacity(0.5)
                    : colors.primary.withOpacity(0.5),
              ),
            ),
            child: Text(
              '${_calculateProgressPercent(provider)}%',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.bold,
                color: provider.status == WorkoutStatus.completed
                    ? Colors.green
                    : colors.primary,
              ),
            ),
          ),
        ),

        // מצב השהיה
        if (provider.status == WorkoutStatus.paused)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: const Icon(
              Icons.pause,
              color: Colors.orange,
              size: 18,
            ),
          ),
      ],
    );
  }

  Widget _buildWorkoutHeader(WorkoutModeProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.colors.primary.withOpacity(0.1),
            AppTheme.colors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.colors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.fitness_center,
              label: 'תרגילים',
              value:
                  '${_getCompletedExercises(provider)}/${provider.workout.exercises.length}',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: _buildStatItem(
              icon: Icons.repeat,
              label: 'סטים',
              value:
                  '${_getCompletedSets(provider)}/${_getTotalSets(provider)}',
            ),
          ),
          _buildDivider(),
          Expanded(
            child: GestureDetector(
              onTap: () => _showFinishWorkoutDialog(provider),
              child: _buildStatItem(
                icon: Icons.flag,
                label: 'סיים אימון',
                value: '',
                isButton: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool isButton = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: isButton ? AppTheme.colors.primary : AppTheme.colors.accent,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.assistant(
            fontSize: 12,
            color: AppTheme.colors.text.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        if (!isButton) ...[
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppTheme.colors.primary.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildRestIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'מנוחה פעילה',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatRestTime(_currentRestSeconds),
                  style: GoogleFonts.assistant(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _currentRestSeconds += 30;
              });
            },
            icon: Icon(Icons.add, color: Colors.blue),
            tooltip: 'הוסף 30 שניות',
          ),
          IconButton(
            onPressed: () {
              _restTimer?.cancel();
              _restTimer = null;
              setState(() {
                _currentRestSeconds = 0;
              });
              _restAnimationController.reverse();
            },
            icon: const Icon(Icons.skip_next, color: Colors.blue),
            tooltip: 'דלג על מנוחה',
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(WorkoutModeProvider provider) {
    if (provider.status == WorkoutStatus.completed) return null;

    final isPaused = provider.status == WorkoutStatus.paused;

    return FloatingActionButton.extended(
      onPressed: () {
        if (isPaused) {
          _resumeWorkout();
        } else {
          _pauseWorkout();
        }
      },
      backgroundColor: isPaused ? Colors.green : Colors.orange,
      elevation: 8,
      icon: Icon(
        isPaused ? Icons.play_arrow : Icons.pause,
        color: Colors.white,
        size: 28,
      ),
      label: Text(
        isPaused ? 'המשך אימון' : 'השהה אימון',
        style: GoogleFonts.assistant(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showFinishWorkoutDialog(WorkoutModeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.flag, color: AppTheme.colors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              'סיום האימון',
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'האם אתה בטוח שתרצה לסיים את האימון?',
              style: GoogleFonts.assistant(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildQuickStats(provider),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishWorkout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'סיים אימון',
              style: GoogleFonts.assistant(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(WorkoutModeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.colors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildStatRow('זמן:', _formatElapsedTime(_elapsedTime)),
          _buildStatRow('סטים:',
              '${_getCompletedSets(provider)}/${_getTotalSets(provider)}'),
          _buildStatRow('התקדמות:', '${_calculateProgressPercent(provider)}%'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.assistant(fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.assistant(
              color: AppTheme.colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(WorkoutModeProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: provider.workout.exercises.length,
      itemBuilder: (context, index) {
        final exercise = provider.workout.exercises[index];
        final exerciseDetails = provider.exerciseDetailsMap[exercise.id];
        final completedSets =
            _getCompletedSetsForExercise(provider, exercise.id);
        final isCompleted = completedSets == exercise.sets.length;
        final isCurrentExercise = _isCurrentExercise(provider, index);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          child: _ExerciseCard(
            exercise: exercise,
            exerciseDetails: exerciseDetails,
            isCompleted: isCompleted,
            isCurrentExercise: isCurrentExercise,
            provider: provider,
            exerciseIndex: index,
            onSetCompleted: (setIndex) {
              _handleSetCompleted(provider, exercise, setIndex);
            },
            onStartRest: (seconds) {
              _startRestTimer(seconds);
            },
          ),
        );
      },
    );
  }

  void _handleSetCompleted(
      WorkoutModeProvider provider, ExerciseModel exercise, int setIndex) {
    HapticFeedback.lightImpact();
    provider.toggleSetComplete(exercise.id, setIndex);

    // התחלת מנוחה אוטומטית אם הסט הושלם
    if (provider.isSetCompleted(exercise.id, setIndex)) {
      final restTime = exercise.restTime ?? 60;
      _startRestTimer(restTime);
    }
  }

  // Helper methods
  String _formatElapsedTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatRestTime(int seconds) {
    if (seconds <= 0) return 'סיום מנוחה';

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  int _calculateProgressPercent(WorkoutModeProvider provider) {
    final totalSets = _getTotalSets(provider);
    final completedSets = _getCompletedSets(provider);

    if (totalSets == 0) return 0;
    return ((completedSets / totalSets) * 100).round();
  }

  int _getTotalSets(WorkoutModeProvider provider) {
    return provider.workout.exercises
        .fold(0, (sum, exercise) => sum + exercise.sets.length);
  }

  int _getCompletedSets(WorkoutModeProvider provider) {
    return provider.completedSets.values
        .fold(0, (sum, sets) => sum + sets.length);
  }

  int _getCompletedExercises(WorkoutModeProvider provider) {
    return provider.workout.exercises.where((exercise) {
      final completed = provider.completedSets[exercise.id] ?? {};
      return completed.length == exercise.sets.length;
    }).length;
  }

  int _getCompletedSetsForExercise(
      WorkoutModeProvider provider, String exerciseId) {
    return provider.completedSets[exerciseId]?.length ?? 0;
  }

  bool _isCurrentExercise(WorkoutModeProvider provider, int index) {
    // התרגיל הנוכחי הוא הראשון שלא הושלם
    for (int i = 0; i < index; i++) {
      final exercise = provider.workout.exercises[i];
      final completed = _getCompletedSetsForExercise(provider, exercise.id);
      if (completed < exercise.sets.length) {
        return false;
      }
    }

    final currentExercise = provider.workout.exercises[index];
    final completed =
        _getCompletedSetsForExercise(provider, currentExercise.id);
    return completed < currentExercise.sets.length;
  }
}

// Exercise Card Widget
class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final ExerciseLib.Exercise? exerciseDetails;
  final bool isCompleted;
  final bool isCurrentExercise;
  final WorkoutModeProvider provider;
  final int exerciseIndex;
  final Function(int) onSetCompleted;
  final Function(int) onStartRest;

  const _ExerciseCard({
    required this.exercise,
    required this.exerciseDetails,
    required this.isCompleted,
    required this.isCurrentExercise,
    required this.provider,
    required this.exerciseIndex,
    required this.onSetCompleted,
    required this.onStartRest,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final completedSets = provider.completedSets[exercise.id] ?? {};

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: isCurrentExercise ? 16 : 8,
            offset: Offset(0, isCurrentExercise ? 6 : 2),
          ),
        ],
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.6)
              : isCurrentExercise
                  ? colors.primary.withOpacity(0.6)
                  : colors.primary.withOpacity(0.2),
          width: isCurrentExercise ? 3 : 1,
        ),
      ),
      child: Column(
        children: [
          // Current exercise indicator
          if (isCurrentExercise)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.primary.withOpacity(0.1),
                    colors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, color: colors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'תרגיל נוכחי',
                    style: GoogleFonts.assistant(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ExerciseHeader(
                  exercise: exercise,
                  exerciseDetails: exerciseDetails,
                  isCompleted: isCompleted,
                  exerciseIndex: exerciseIndex,
                ),
                const SizedBox(height: 12),
                ExerciseProgressBar(
                  total: exercise.sets.length,
                  completed: completedSets.length,
                ),
                const SizedBox(height: 16),
                _ExerciseSetsList(
                  exercise: exercise,
                  provider: provider,
                  onSetCompleted: onSetCompleted,
                  onStartRest: onStartRest,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Exercise Header Widget
class _ExerciseHeader extends StatelessWidget {
  final ExerciseModel exercise;
  final ExerciseLib.Exercise? exerciseDetails;
  final bool isCompleted;
  final int exerciseIndex;

  const _ExerciseHeader({
    required this.exercise,
    required this.exerciseDetails,
    required this.isCompleted,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Exercise number
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: isCompleted
                ? const LinearGradient(
                    colors: [Colors.green, Color(0xFF4CAF50)],
                  )
                : LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.2),
                      colors.primary.withOpacity(0.1),
                    ],
                  ),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? Colors.green : colors.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${exerciseIndex + 1}',
                    style: GoogleFonts.assistant(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 12),

        // Exercise image or icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: exerciseDetails?.displayImage?.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    exerciseDetails!.displayImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.fitness_center,
                      color: colors.primary,
                      size: 24,
                    ),
                  ),
                )
              : Icon(
                  Icons.fitness_center,
                  color: colors.primary,
                  size: 24,
                ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: GestureDetector(
            onTap: () {
              if (exerciseDetails != null) {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppTheme.colors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (ctx) => ExerciseQuickView(
                    exercise: exerciseDetails!,
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.headline,
                  ),
                ),
                if (exerciseDetails != null)
                  Text(
                    exerciseDetails!.primaryMuscles
                        .map((m) => m.hebrewName)
                        .join(', '),
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: colors.text.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Rest time indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: 14, color: colors.accent),
              const SizedBox(width: 4),
              Text(
                '${exercise.restTime ?? 60}s',
                style: GoogleFonts.assistant(
                  fontSize: 12,
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Exercise Sets List Widget
class _ExerciseSetsList extends StatelessWidget {
  final ExerciseModel exercise;
  final WorkoutModeProvider provider;
  final Function(int) onSetCompleted;
  final Function(int) onStartRest;

  const _ExerciseSetsList({
    required this.exercise,
    required this.provider,
    required this.onSetCompleted,
    required this.onStartRest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: exercise.sets.asMap().entries.map((entry) {
        final index = entry.key;
        final set = entry.value;
        final isCompleted = provider.isSetCompleted(exercise.id, index);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: SetRow(
            setIdx: index,
            set: set,
            isDone: isCompleted,
            isResting: false, // We handle rest globally now
            restSeconds: 0,
            onToggleDone: () => onSetCompleted(index),
            onEdit: () => _showEditSetDialog(context, index, set),
          ),
        );
      }).toList(),
    );
  }

  void _showEditSetDialog(BuildContext context, int setIndex, ExerciseSet set) {
    showDialog(
      context: context,
      builder: (context) => EditSetDialog(
        exId: exercise.id,
        setIdx: setIndex,
        set: set,
        onSave: (updatedSet) {
          provider.updateSet(exercise.id, setIndex, updatedSet);
        },
        onDelete: exercise.sets.length > 1
            ? () => provider.deleteSet(exercise.id, setIndex)
            : () {},
        onAdd: () => provider.addSet(exercise.id, afterSetIdx: setIndex),
      ),
    );
  }
}
