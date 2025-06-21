// lib/features/workouts/screens/workouts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/workout_model.dart';
import '../providers/workouts_provider.dart';
import 'new_workout_screen.dart';
import 'workout_details_screen.dart';
import 'workout_mode/workout_mode_screen.dart';
import '../../../providers/exercise_provider.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;

  String _selectedFilter = 'הכל';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeInOut,
    ));

    _headerAnimationController.forward();
    _listAnimationController.forward(from: 0.3);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutsProvider(),
      child: _WorkoutsView(
        headerAnimation: _headerAnimation,
        listAnimation: _listAnimation,
        selectedFilter: _selectedFilter,
        searchQuery: _searchQuery,
        searchController: _searchController,
        isSearching: _isSearching,
        onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
        onSearchChanged: (query) => setState(() => _searchQuery = query),
        onSearchToggle: () => setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) {
            _searchController.clear();
            _searchQuery = '';
          }
        }),
      ),
    );
  }
}

class _WorkoutsView extends StatelessWidget {
  final Animation<double> headerAnimation;
  final Animation<double> listAnimation;
  final String selectedFilter;
  final String searchQuery;
  final TextEditingController searchController;
  final bool isSearching;
  final Function(String) onFilterChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchToggle;

  const _WorkoutsView({
    required this.headerAnimation,
    required this.listAnimation,
    required this.selectedFilter,
    required this.searchQuery,
    required this.searchController,
    required this.isSearching,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAnimatedHeader(context),
              _buildSearchAndFilters(context),
              Expanded(
                child: provider.isLoading
                    ? _buildLoadingState()
                    : _buildContent(context, provider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFAB(context),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: headerAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: headerAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - headerAnimation.value)),
            child: Opacity(
              opacity: headerAnimation.value,
              child: _buildHeader(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final provider = context.watch<WorkoutsProvider>();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf093fb).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'האימונים שלי',
                  style: GoogleFonts.assistant(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${provider.workouts.length} אימונים זמינים',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSearchToggle,
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isSearching ? 120 : 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // שורת הפילטרים
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('הכל'),
                _buildFilterChip('אחרונים'),
                _buildFilterChip('מועדפים'),
                _buildFilterChip('חזה'),
                _buildFilterChip('גב'),
                _buildFilterChip('רגליים'),
                _buildFilterChip('כתפיים'),
              ],
            ),
          ),

          // שורת החיפוש
          if (isSearching) ...[
            const SizedBox(height: 12),
            AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: isSearching ? Offset.zero : const Offset(0, -1),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: GoogleFonts.assistant(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'חפש אימון...',
                    hintStyle: GoogleFonts.assistant(
                      color: Colors.white.withOpacity(0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          filter,
          style: GoogleFonts.assistant(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onFilterChanged(filter),
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: Colors.white,
        checkmarkColor: Colors.black,
        side: BorderSide(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'טוען אימונים...',
            style: GoogleFonts.assistant(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutsProvider provider) {
    final filteredWorkouts = _getFilteredWorkouts(provider.workouts);

    if (filteredWorkouts.isEmpty) {
      return provider.workouts.isEmpty
          ? _buildEmptyState(context)
          : _buildNoResultsState(context);
    }

    return _buildWorkoutsList(context, filteredWorkouts);
  }

  List<WorkoutModel> _getFilteredWorkouts(List<WorkoutModel> workouts) {
    var filtered = workouts;

    // חיפוש טקסט
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((workout) {
        return workout.title
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            (workout.description
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // פילטר קטגוריה
    if (selectedFilter != 'הכל') {
      switch (selectedFilter) {
        case 'אחרונים':
          filtered = filtered.take(5).toList();
          break;
        case 'מועדפים':
          // כאן תוכל לטפל במועדפים
          break;
        default:
          // פילטר לפי סוג שריר
          filtered = filtered.where((workout) {
            return workout.title
                    .toLowerCase()
                    .contains(selectedFilter.toLowerCase()) ||
                workout.exercises.any((exercise) => exercise.name
                    .toLowerCase()
                    .contains(selectedFilter.toLowerCase()));
          }).toList();
      }
    }

    return filtered;
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'לא נמצאו תוצאות',
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'נסה לשנות את החיפוש או הפילטר',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF43e97b).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'אין לך אימונים עדיין',
                    style: GoogleFonts.assistant(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'התחל ליצור אימונים מותאמים אישית',
                    style: GoogleFonts.assistant(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildCreateWorkoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateWorkoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4facfe).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToNewWorkout(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'צור אימון חדש',
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutsList(BuildContext context, List<WorkoutModel> workouts) {
    return AnimatedBuilder(
      animation: listAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: listAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - listAnimation.value)),
            child: RefreshIndicator(
              onRefresh: () async {
                final provider = context.read<WorkoutsProvider>();
                await provider.loadWorkouts();
              },
              color: Colors.white,
              backgroundColor: const Color(0xFF667eea),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 100)),
                    curve: Curves.easeOutBack,
                    child: _WorkoutCard(
                      workout: workouts[index],
                      index: index,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFAB(BuildContext context) {
    return AnimatedBuilder(
      animation: listAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: listAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4facfe).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToNewWorkout(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'אימון חדש',
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToNewWorkout(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewWorkoutScreen()),
    );
  }
}

class _WorkoutCard extends StatefulWidget {
  final WorkoutModel workout;
  final int index;

  const _WorkoutCard({
    required this.workout,
    required this.index,
  });

  @override
  State<_WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<_WorkoutCard>
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

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutsProvider>();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.9),
                  Color(0xFF764ba2).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _navigateToWorkoutDetails(context);
                },
                onTapDown: (_) {
                  _animationController.forward();
                  setState(() => _isPressed = true);
                },
                onTapUp: (_) {
                  _animationController.reverse();
                  setState(() => _isPressed = false);
                },
                onTapCancel: () {
                  _animationController.reverse();
                  setState(() => _isPressed = false);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(_isPressed ? 0.4 : 0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, provider),
                        const SizedBox(height: 12),
                        _buildWorkoutInfo(),
                        const SizedBox(height: 16),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutsProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.workout.title,
                style: GoogleFonts.assistant(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.workout.description != null &&
                  widget.workout.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  widget.workout.description!,
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(
                      'ערוך אימון',
                      style: GoogleFonts.assistant(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    const Icon(Icons.copy),
                    const SizedBox(width: 8),
                    Text(
                      'שכפל אימון',
                      style: GoogleFonts.assistant(),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text(
                      'שתף אימון',
                      style: GoogleFonts.assistant(),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'מחק אימון',
                      style: GoogleFonts.assistant(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutInfo() {
    final totalSets = widget.workout.exercises
        .fold<int>(0, (sum, exercise) => sum + exercise.sets.length);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildInfoChip(
          Icons.fitness_center,
          '${widget.workout.exercises.length} תרגילים',
        ),
        _buildInfoChip(
          Icons.repeat,
          '$totalSets סטים',
        ),
        _buildInfoChip(
          Icons.schedule,
          _getEstimatedTime(),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.assistant(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            onTap: () => _navigateToWorkoutDetails(context),
            icon: Icons.info_outline,
            label: 'פרטים',
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildActionButton(
            onTap: () => _startWorkout(context),
            icon: Icons.play_arrow,
            label: 'התחל אימון',
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Colors.white, Color(0xFFf8f9fa)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: isPrimary
                      ? BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  child: Icon(
                    icon,
                    color: isPrimary
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.assistant(
                    color: isPrimary ? const Color(0xFF2d3748) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getEstimatedTime() {
    int totalMinutes = 0;
    for (final exercise in widget.workout.exercises) {
      // זמן ביצוע משוער (30 שניות לסט) + זמן מנוחה
      totalMinutes += exercise.sets.length * 1; // דקה לכל סט בממוצע
    }
    return '${totalMinutes}ד';
  }

  void _navigateToWorkoutDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutDetailsScreen(workout: widget.workout),
      ),
    );
  }

  void _startWorkout(BuildContext context) async {
    final provider = context.read<WorkoutsProvider>();

    try {
      final exerciseDetails = await provider.getExerciseDetails(widget.workout);

      if (!context.mounted) return;

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'שגיאה בטעינת האימון: $e',
              style: GoogleFonts.assistant(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    final provider = context.read<WorkoutsProvider>();

    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NewWorkoutScreen(),
          ),
        );
        break;

      case 'duplicate':
        _duplicateWorkout(context, provider);
        break;

      case 'share':
        _shareWorkout(context);
        break;

      case 'delete':
        _showDeleteDialog(context, provider);
        break;
    }
  }

  void _duplicateWorkout(BuildContext context, WorkoutsProvider provider) {
    // provider.duplicateWorkout(widget.workout);
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

  void _shareWorkout(BuildContext context) {
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

  void _showDeleteDialog(BuildContext context, WorkoutsProvider provider) {
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
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.deleteWorkout(widget.workout.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'האימון נמחק בהצלחה',
                    style: GoogleFonts.assistant(),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'מחק',
              style: GoogleFonts.assistant(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
