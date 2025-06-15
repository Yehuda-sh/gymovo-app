import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/exercise.dart';
import '../../../models/exercise_history.dart';
import '../../../providers/exercise_history_provider.dart';
import '../../../theme/app_theme.dart';
import '../widgets/exercise_media_section.dart';
import '../widgets/exercise_history_graph.dart';
import '../widgets/exercise_set_form.dart';
import '../widgets/exercise_set_list.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late AnimationController _fabAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fabAnimation;

  String? _undoSetId;
  ExerciseSet? _lastDeletedSet;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // קבועים פרטיים
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Duration _staggerDelay = Duration(milliseconds: 100);
  static const double _cardBorderRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _loadData();
  }

  void _setupControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    _fadeAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
  }

  void _setupAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      await context.read<ExerciseHistoryProvider>().loadExerciseHistories();

      if (mounted) {
        setState(() => _isLoading = false);

        // התחל אנימציות
        _fadeAnimationController.forward();
        await Future.delayed(_staggerDelay);
        _scaleAnimationController.forward();
        await Future.delayed(_staggerDelay);
        _fabAnimationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
        _showErrorSnackBar('שגיאה בטעינת הנתונים: ${e.toString()}');
      }
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.selectionClick();

      // הסתר FAB בטאב היסטוריה
      if (_tabController.index == 1) {
        _fabAnimationController.reverse();
      } else {
        _fabAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleSetSave(ExerciseSet set) async {
    try {
      if (set.id == _lastDeletedSet?.id) {
        _lastDeletedSet = null;
      }

      final provider = context.read<ExerciseHistoryProvider>();
      if (set.id == _lastDeletedSet?.id) {
        await provider.updateSet(widget.exercise.id, set);
      } else {
        await provider.addSet(widget.exercise.id, set);
      }

      if (mounted) {
        HapticFeedback.lightImpact();
        _showSuccessSnackBar('הסט נשמר בהצלחה');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('שגיאה בשמירת הסט: ${e.toString()}');
      }
    }
  }

  Future<void> _handleSetDelete(String setId) async {
    try {
      final provider = context.read<ExerciseHistoryProvider>();
      final history = provider.getExerciseHistory(widget.exercise.id);

      if (history != null) {
        _lastDeletedSet = history.sets.firstWhere(
          (set) => set.id == setId,
          orElse: () => throw Exception('סט לא נמצא'),
        );

        await provider.deleteSet(widget.exercise.id, setId);

        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'הסט נמחק',
                style: GoogleFonts.assistant(),
              ),
              action: SnackBarAction(
                label: 'בטל',
                onPressed: _undoDeleteSet,
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('שגיאה במחיקת הסט: ${e.toString()}');
      }
    }
  }

  Future<void> _undoDeleteSet() async {
    if (_lastDeletedSet != null) {
      try {
        await context.read<ExerciseHistoryProvider>().addSet(
              widget.exercise.id,
              _lastDeletedSet!,
            );
        _lastDeletedSet = null;

        if (mounted) {
          HapticFeedback.lightImpact();
          _showSuccessSnackBar('הסט שוחזר');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('שגיאה בשחזור הסט: ${e.toString()}');
        }
      }
    }
  }

  Future<void> _handleSetEdit(ExerciseSet set) async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<ExerciseSet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: ExerciseSetForm(
          exerciseId: widget.exercise.id,
          existingSet: set,
          onSave: (updatedSet) {
            Navigator.pop(context, updatedSet);
          },
        ),
      ),
    );

    if (result != null) {
      await _handleSetSave(result);
    }
  }

  Future<void> _showAddSetDialog() async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<ExerciseSet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: ExerciseSetForm(
          exerciseId: widget.exercise.id,
          onSave: (set) {
            Navigator.pop(context, set);
          },
        ),
      ),
    );

    if (result != null) {
      await _handleSetSave(result);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'נסה שוב',
          textColor: Colors.white,
          onPressed: _loadData,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, {Color? color, IconData? icon}) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? colors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? colors.primary).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color ?? colors.primary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.assistant(
              color: color ?? colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    if (_isLoading) {
      return _buildLoadingState(colors);
    }

    if (_hasError) {
      return _buildErrorState(colors);
    }

    return Consumer<ExerciseHistoryProvider>(
      builder: (context, provider, child) {
        final history = provider.getExerciseHistory(widget.exercise.id);
        final sets = history?.sets ?? [];

        return Scaffold(
          backgroundColor: colors.background,
          appBar: _buildAppBar(colors, sets),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(),
                  _buildHistoryTab(sets),
                  _buildSetsTab(sets),
                ],
              ),
            ),
          ),
          floatingActionButton: ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.extended(
              onPressed: _showAddSetDialog,
              icon: const Icon(Icons.add),
              label: Text(
                'הוסף סט',
                style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colors.primary,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          widget.exercise.name,
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'טוען נתונים...',
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: colors.text.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          widget.exercise.name,
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: colors.error.withOpacity(0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'שגיאה בטעינת הנתונים',
                style: GoogleFonts.assistant(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.text.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'נסה שוב',
                  style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors, List<ExerciseSet> sets) {
    return AppBar(
      title: Text(
        widget.exercise.name,
        style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
      ),
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [
        if (sets.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'סטטיסטיקות',
            onPressed: () {
              HapticFeedback.lightImpact();
              _tabController.animateTo(1);
            },
          ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'שתף תרגיל',
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: הוסף שיתוף תרגיל
            _showSuccessSnackBar('שיתוף יפותח בקרוב');
          },
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: colors.primary,
        labelColor: colors.primary,
        unselectedLabelColor: colors.text.withOpacity(0.6),
        labelStyle: GoogleFonts.assistant(fontWeight: FontWeight.w600),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: 'מידע'),
          Tab(icon: Icon(Icons.timeline), text: 'היסטוריה'),
          Tab(icon: Icon(Icons.fitness_center), text: 'סטים'),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExerciseMediaSection(exercise: widget.exercise),
            const SizedBox(height: 20),
            if (widget.exercise.mainMuscles?.isNotEmpty ?? false) ...[
              _buildSectionCard(
                title: 'שרירים מעורבים',
                icon: Icons.fitness_center,
                color: AppTheme.colors.secondary,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.exercise.mainMuscles!
                      .map((muscle) => _buildInfoChip(
                            muscle,
                            icon: Icons.fitness_center,
                            color: AppTheme.colors.secondary,
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.exercise.description?.isNotEmpty ?? false) ...[
              _buildSectionCard(
                title: 'תיאור התרגיל',
                icon: Icons.description,
                color: AppTheme.colors.primary,
                child: Text(
                  widget.exercise.description!,
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    color: AppTheme.colors.text,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.exercise.instructions?.isNotEmpty ?? false) ...[
              _buildSectionCard(
                title: 'הוראות ביצוע',
                icon: Icons.list_alt,
                color: AppTheme.colors.accent,
                child: Column(
                  children: widget.exercise.instructions!
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildInstructionItem(entry.key, entry.value))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.exercise.tips?.isNotEmpty ?? false) ...[
              _buildSectionCard(
                title: 'טיפים חשובים',
                icon: Icons.lightbulb_outline,
                color: Colors.amber,
                backgroundColor: Colors.amber.withOpacity(0.1),
                child: Column(
                  children: widget.exercise.tips!
                      .map((tip) => _buildTipItem(tip))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int index, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.colors.accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.colors.accent.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: GoogleFonts.assistant(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              instruction,
              style: GoogleFonts.assistant(
                fontSize: 15,
                color: AppTheme.colors.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Colors.amber[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.assistant(
                fontSize: 14,
                color: AppTheme.colors.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<ExerciseSet> sets) {
    if (sets.isEmpty) {
      return _buildEmptyHistoryState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(_cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: AppTheme.colors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'גרף התקדמות',
                      style: GoogleFonts.assistant(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.colors.headline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExerciseHistoryGraph(sets: sets),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsCards(sets),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 80,
              color: AppTheme.colors.text.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'אין היסטוריה להצגה',
              style: GoogleFonts.assistant(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.colors.headline,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'התחל להוסיף סטים כדי לראות את ההתקדמות שלך',
              style: GoogleFonts.assistant(
                fontSize: 14,
                color: AppTheme.colors.text.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddSetDialog,
              icon: const Icon(Icons.add),
              label: Text(
                'הוסף סט ראשון',
                style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetsTab(List<ExerciseSet> sets) {
    return ExerciseSetList(
      sets: sets,
      onEdit: _handleSetEdit,
      onDelete: _handleSetDelete,
      showDate: true,
    );
  }

  Widget _buildStatsCards(List<ExerciseSet> sets) {
    if (sets.isEmpty) return const SizedBox.shrink();

    final maxWeight =
        sets.map((s) => s.weight ?? 0).reduce((a, b) => a > b ? a : b);
    final maxReps =
        sets.map((s) => s.reps ?? 0).reduce((a, b) => a > b ? a : b);
    final totalSets = sets.length;
    final completedSets = sets.where((s) => s.isCompleted).length;
    final avgWeight = sets.isNotEmpty
        ? (sets.map((s) => s.weight ?? 0).reduce((a, b) => a + b) / sets.length)
        : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'משקל מקסימלי',
          '${maxWeight.toInt()} ק"ג',
          Icons.fitness_center,
          Colors.blue,
        ),
        _buildStatCard(
          'חזרות מקסימליות',
          maxReps.toString(),
          Icons.repeat,
          Colors.green,
        ),
        _buildStatCard(
          'סך סטים',
          totalSets.toString(),
          Icons.format_list_numbered,
          Colors.orange,
        ),
        _buildStatCard(
          'סטים שהושלמו',
          '$completedSets/$totalSets',
          Icons.check_circle,
          Colors.purple,
        ),
        _buildStatCard(
          'משקל ממוצע',
          '${avgWeight.toStringAsFixed(1)} ק"ג',
          Icons.analytics,
          Colors.teal,
        ),
        _buildStatCard(
          'אחוז השלמה',
          '${((completedSets / totalSets) * 100).toInt()}%',
          Icons.trending_up,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors.surface,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.text.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
