// lib/screens/select_exercises/select_exercises_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/exercise.dart';
import '../../services/exercise_image_service.dart';
import '../../theme/app_theme.dart';
import 'exercise_image_picker_screen.dart';

class SelectExercisesScreen extends StatefulWidget {
  final List<Exercise> initiallySelected;
  final bool multiSelect;
  final String? title;
  final Function(List<Exercise>)? onSelectionChanged;

  const SelectExercisesScreen({
    super.key,
    this.initiallySelected = const [],
    this.multiSelect = true,
    this.title,
    this.onSelectionChanged,
  });

  @override
  State<SelectExercisesScreen> createState() => _SelectExercisesScreenState();
}

class _SelectExercisesScreenState extends State<SelectExercisesScreen>
    with TickerProviderStateMixin {
  List<Exercise> _exercises = [];
  Set<String> _selectedIds = {};
  String _search = '';
  bool _isLoading = true;
  String? _error;
  Map<String, String> _exerciseImages = {};
  bool _showImages = true;

  // פילטרים
  List<MuscleGroup> _selectedMuscleGroups = [];
  List<ExerciseEquipment> _selectedEquipment = [];
  List<ExerciseDifficulty> _selectedDifficulties = [];
  List<ExerciseType> _selectedTypes = [];

  late TabController _tabController;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  // קטגוריות של קבוצות שרירים
  final List<MuscleGroup> _muscleCategories = [
    MuscleGroup.fullBody, // הכל
    MuscleGroup.chest,
    MuscleGroup.back,
    MuscleGroup.shoulders,
    MuscleGroup.biceps,
    MuscleGroup.triceps,
    MuscleGroup.legs,
    MuscleGroup.glutes,
    MuscleGroup.core,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initiallySelected.map((e) => e.id).toSet();
    _tabController =
        TabController(length: _muscleCategories.length, vsync: this);
    _setupAnimations();
    _loadExercises();
  }

  void _setupAnimations() {
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // טעינת תרגילים מובנים או מ-JSON
      final exercises = await _loadExercisesFromSource();

      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });

      // טען תמונות ברקע
      _loadExerciseImagesInBackground(exercises);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<List<Exercise>> _loadExercisesFromSource() async {
    try {
      // נסה לטעון מ-JSON
      final data =
          await rootBundle.loadString('assets/data/workout_exercises.json');
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((json) => Exercise.fromJson(json)).toList();
    } catch (e) {
      // אם לא מצליח, השתמש בתרגילים מובנים
      return _getBuiltInExercises();
    }
  }

  List<Exercise> _getBuiltInExercises() {
    return [
      Exercise.pushUp(),
      Exercise.squat(),
      Exercise(
        id: 'deadlift_001',
        name: 'Deadlift',
        nameHe: 'הרמת מטען',
        description: 'Fundamental compound exercise for posterior chain',
        descriptionHe: 'תרגיל יסוד מורכב לשרשרת האחורית',
        instructions: [
          'Stand with feet hip-width apart',
          'Bend at hips and knees to grasp barbell',
          'Keep back straight and chest up',
          'Drive through heels to stand up'
        ],
        instructionsHe: [
          'עמוד עם רגליים ברוחב הירכיים',
          'התכופף בירכיים וברכיים לאחיזת המוט',
          'שמור על גב ישר וחזה פתוח',
          'דחף דרך העקבים לעמידה'
        ],
        type: ExerciseType.compound,
        equipment: ExerciseEquipment.barbell,
        difficulty: ExerciseDifficulty.advanced,
        primaryMuscles: [MuscleGroup.back, MuscleGroup.legs],
        secondaryMuscles: [MuscleGroup.core, MuscleGroup.traps],
        tags: ['גב', 'רגליים', 'כוח', 'מורכב'],
        isVerified: true,
        rating: 4.8,
        ratingCount: 1500,
      ),
      Exercise(
        id: 'pullup_001',
        name: 'Pull-up',
        nameHe: 'מתח',
        description: 'Upper body compound exercise',
        descriptionHe: 'תרגיל מורכב לחלק העליון',
        instructions: [
          'Hang from pull-up bar with overhand grip',
          'Pull body up until chin clears bar',
          'Lower with control to starting position'
        ],
        instructionsHe: [
          'תלה על מוט מתח באחיזה עליונה',
          'משוך את הגוף עד שהסנטר עובר את המוט',
          'רד בשליטה למצב ההתחלה'
        ],
        type: ExerciseType.compound,
        equipment: ExerciseEquipment.pullupBar,
        difficulty: ExerciseDifficulty.hard,
        primaryMuscles: [MuscleGroup.back, MuscleGroup.lats],
        secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.core],
        tags: ['גב', 'ביצפס', 'מתח', 'מורכב'],
        isVerified: true,
        rating: 4.6,
        ratingCount: 980,
      ),
    ];
  }

  Future<void> _loadExerciseImagesInBackground(List<Exercise> exercises) async {
    final futures = exercises.map((exercise) async {
      String imageUrl = exercise.displayImage;

      if (imageUrl.isEmpty) imageUrl = '';

      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        final isValid = await ExerciseImageService.isImageUrlValid(imageUrl)
            .catchError((_) => false);
        if (!isValid) {
          imageUrl = ExerciseImageService.getDefaultExerciseImage(
            exercise.type.name,
            exercise.primaryMuscles.isNotEmpty
                ? exercise.primaryMuscles.first.name
                : 'chest',
          );
        }
      }

      return MapEntry(exercise.id, imageUrl);
    });

    final results = await Future.wait(futures);
    final Map<String, String> imagesMap = Map.fromEntries(results);

    if (mounted) {
      setState(() {
        _exerciseImages = imagesMap;
      });
    }
  }

  List<Exercise> get _filteredExercises {
    return _exercises.where((exercise) {
      // פילטור לפי חיפוש
      final matchesSearch =
          _search.isEmpty || exercise.matchesQuery(_search, 'he');

      // פילטור לפי קבוצות שרירים
      final matchesMuscleGroups = _selectedMuscleGroups.isEmpty ||
          exercise.primaryMuscles
              .any((muscle) => _selectedMuscleGroups.contains(muscle)) ||
          exercise.secondaryMuscles
              .any((muscle) => _selectedMuscleGroups.contains(muscle));

      // פילטור לפי ציוד
      final matchesEquipment = _selectedEquipment.isEmpty ||
          _selectedEquipment.contains(exercise.equipment);

      // פילטור לפי קושי
      final matchesDifficulty = _selectedDifficulties.isEmpty ||
          _selectedDifficulties.contains(exercise.difficulty);

      // פילטור לפי סוג תרגיל
      final matchesType =
          _selectedTypes.isEmpty || _selectedTypes.contains(exercise.type);

      // פילטור לפי קטגוריה נבחרת בטאב
      final selectedCategory = _muscleCategories[_tabController.index];
      final matchesCategory = selectedCategory == MuscleGroup.fullBody ||
          exercise.primaryMuscles.contains(selectedCategory) ||
          exercise.secondaryMuscles.contains(selectedCategory);

      return matchesSearch &&
          matchesMuscleGroups &&
          matchesEquipment &&
          matchesDifficulty &&
          matchesType &&
          matchesCategory;
    }).toList();
  }

  void _toggleSelect(Exercise exercise) {
    setState(() {
      if (_selectedIds.contains(exercise.id)) {
        _selectedIds.remove(exercise.id);
      } else {
        if (!widget.multiSelect) {
          _selectedIds.clear();
        }
        _selectedIds.add(exercise.id);
      }
    });

    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(
          _exercises.where((e) => _selectedIds.contains(e.id)).toList());
    }
  }

  Widget _buildExerciseImage(Exercise exercise) {
    final colors = AppTheme.colors;
    final imageUrl = _exerciseImages[exercise.id] ?? '';
    final isLoading = imageUrl.isEmpty;

    return GestureDetector(
      onTap: () => _showExercisePreview(exercise),
      child: Hero(
        tag: 'exercise_image_${exercise.id}',
        child: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: _buildImageContent(imageUrl, isLoading, colors),
              ),
            ),

            // אינדיקטור תרגיל מאומת
            if (exercise.isVerified)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),

            // כפתור עריכת תמונה
            if (!isLoading)
              Positioned(
                bottom: -2,
                left: -2,
                child: GestureDetector(
                  onTap: () => _showImagePicker(exercise),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(String imageUrl, bool isLoading, AppColors colors) {
    if (isLoading) {
      return Container(
        color: colors.surface,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(colors),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: colors.surface,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildErrorImage(colors),
    );
  }

  Widget _buildErrorImage(AppColors colors) {
    return Container(
      color: colors.surface,
      child: Icon(
        Icons.fitness_center,
        color: colors.primary,
        size: 28,
      ),
    );
  }

  void _showExercisePreview(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => _ExercisePreviewDialog(
        exercise: exercise,
        imageUrl: _exerciseImages[exercise.id] ?? '',
        isSelected: _selectedIds.contains(exercise.id),
        onToggleSelect: () => _toggleSelect(exercise),
      ),
    );
  }

  Future<void> _showImagePicker(Exercise exercise) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ExerciseImagePickerScreen(
          exerciseName: exercise.nameHe,
          exerciseType: exercise.type.name,
          mainMuscle: exercise.primaryMuscles.isNotEmpty
              ? exercise.primaryMuscles.first.name
              : 'chest',
          currentImageUrl: _exerciseImages[exercise.id],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _exerciseImages[exercise.id] = result;
      });
    }
  }

  Widget _buildFilterSection() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      child: _FilterPanel(
        selectedMuscleGroups: _selectedMuscleGroups,
        selectedEquipment: _selectedEquipment,
        selectedDifficulties: _selectedDifficulties,
        selectedTypes: _selectedTypes,
        onMuscleGroupsChanged: (groups) {
          setState(() {
            _selectedMuscleGroups = groups;
          });
        },
        onEquipmentChanged: (equipment) {
          setState(() {
            _selectedEquipment = equipment;
          });
        },
        onDifficultiesChanged: (difficulties) {
          setState(() {
            _selectedDifficulties = difficulties;
          });
        },
        onTypesChanged: (types) {
          setState(() {
            _selectedTypes = types;
          });
        },
        onClearAll: () {
          setState(() {
            _selectedMuscleGroups.clear();
            _selectedEquipment.clear();
            _selectedDifficulties.clear();
            _selectedTypes.clear();
          });
        },
      ),
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_filterAnimation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final hasActiveFilters = _selectedMuscleGroups.isNotEmpty ||
        _selectedEquipment.isNotEmpty ||
        _selectedDifficulties.isNotEmpty ||
        _selectedTypes.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? 'בחר תרגילים',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        actions: [
          // כפתור פילטרים
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              if (_filterAnimationController.isCompleted) {
                _filterAnimationController.reverse();
              } else {
                _filterAnimationController.forward();
              }
            },
            tooltip: 'פילטרים',
          ),
          // כפתור תצוגת תמונות
          IconButton(
            icon: Icon(_showImages ? Icons.image_not_supported : Icons.image),
            onPressed: () {
              setState(() {
                _showImages = !_showImages;
              });
            },
            tooltip: _showImages ? 'הסתר תמונות' : 'הצג תמונות',
          ),
          // כפתור רענון
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
            tooltip: 'רענן',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelStyle: GoogleFonts.assistant(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.assistant(),
          tabs: _muscleCategories
              .map((muscle) => Tab(
                    text: muscle == MuscleGroup.fullBody
                        ? 'הכל'
                        : muscle.hebrewName,
                  ))
              .toList(),
          onTap: (index) {
            setState(() {}); // רענון הרשימה
          },
        ),
      ),
      body: Column(
        children: [
          // שורת חיפוש
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'חפש תרגיל, שריר או תיאור...',
                hintStyle: GoogleFonts.assistant(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _search = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              style: GoogleFonts.assistant(),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),

          // פאנל פילטרים
          _buildFilterSection(),

          // מונה תוצאות
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredExercises.length} תרגילים',
                  style: GoogleFonts.assistant(
                    color: colors.text.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  Text(
                    '${_selectedIds.length} נבחרו',
                    style: GoogleFonts.assistant(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // רשימת תרגילים
          Expanded(
            child: _buildExercisesList(),
          ),
        ],
      ),
      floatingActionButton: _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                final selectedExercises = _exercises
                    .where((e) => _selectedIds.contains(e.id))
                    .toList();
                Navigator.of(context).pop(selectedExercises);
              },
              backgroundColor: colors.primary,
              icon: const Icon(Icons.check, color: Colors.white),
              label: Text(
                widget.multiSelect
                    ? 'הוסף ${_selectedIds.length} תרגילים'
                    : 'בחר תרגיל',
                style: GoogleFonts.assistant(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildExercisesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'שגיאה בטעינת תרגילים',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.assistant(
                color: AppTheme.colors.text.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExercises,
              child: Text(
                'נסה שוב',
                style: GoogleFonts.assistant(),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.colors.text.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'לא נמצאו תרגילים',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'נסה לשנות את החיפוש או הפילטרים',
              style: GoogleFonts.assistant(
                color: AppTheme.colors.text.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        return _ExerciseListItem(
          exercise: exercise,
          isSelected: _selectedIds.contains(exercise.id),
          showImage: _showImages,
          imageWidget: _showImages ? _buildExerciseImage(exercise) : null,
          onTap: () => _toggleSelect(exercise),
          onImageTap: () => _showExercisePreview(exercise),
        );
      },
    );
  }
}

// Widget נפרד לפריט ברשימה
class _ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final bool showImage;
  final Widget? imageWidget;
  final VoidCallback onTap;
  final VoidCallback onImageTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.isSelected,
    required this.showImage,
    this.imageWidget,
    required this.onTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: isSelected ? colors.primary.withOpacity(0.1) : colors.surface,
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? colors.primary.withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: showImage ? imageWidget : null,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  exercise.nameHe,
                  style: GoogleFonts.assistant(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? colors.primary : colors.headline,
                    fontSize: 16,
                  ),
                ),
              ),
              if (exercise.isVerified)
                Icon(
                  Icons.verified,
                  size: 16,
                  color: Colors.green,
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // תגיות מידע
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _InfoChip(
                    icon: Icons.star,
                    label: exercise.difficulty.hebrewName,
                    color: exercise.difficulty.color,
                  ),
                  _InfoChip(
                    icon: Icons.build,
                    label: exercise.equipment.hebrewName,
                    color: colors.accent,
                  ),
                  if (exercise.primaryMuscles.isNotEmpty)
                    _InfoChip(
                      icon: Icons.accessibility_new,
                      label: exercise.primaryMuscles.first.hebrewName,
                      color: colors.primary,
                    ),
                ],
              ),
              if (exercise.rating > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < exercise.rating.round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 14,
                        color: Colors.amber,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '(${exercise.ratingCount})',
                      style: GoogleFonts.assistant(
                        fontSize: 12,
                        color: colors.text.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (_) => onTap(),
            activeColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

// Widget לתג מידע
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// דיאלוג תצוגה מקדימה של תרגיל
class _ExercisePreviewDialog extends StatelessWidget {
  final Exercise exercise;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onToggleSelect;

  const _ExercisePreviewDialog({
    required this.exercise,
    required this.imageUrl,
    required this.isSelected,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // כותרת
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.nameHe,
                    style: GoogleFonts.assistant(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: colors.primary,
                ),
              ],
            ),
          ),

          // תוכן
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // תמונה
                    if (imageUrl.isNotEmpty)
                      Center(
                        child: Hero(
                          tag: 'exercise_image_${exercise.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 200,
                                      color: colors.surface,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 200,
                                      color: colors.surface,
                                      child: Icon(
                                        Icons.fitness_center,
                                        size: 48,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // פרטי התרגיל
                    _PreviewSection(
                      title: 'פרטי התרגיל',
                      children: [
                        _PreviewRow('רמת קושי', exercise.difficulty.hebrewName),
                        _PreviewRow('ציוד', exercise.equipment.hebrewName),
                        _PreviewRow('סוג', exercise.type.hebrewName),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // שרירים
                    _PreviewSection(
                      title: 'שרירים מעורבים',
                      children: [
                        if (exercise.primaryMuscles.isNotEmpty)
                          _PreviewRow(
                            'שרירים ראשיים',
                            exercise.primaryMuscles
                                .map((m) => m.hebrewName)
                                .join(', '),
                          ),
                        if (exercise.secondaryMuscles.isNotEmpty)
                          _PreviewRow(
                            'שרירים משניים',
                            exercise.secondaryMuscles
                                .map((m) => m.hebrewName)
                                .join(', '),
                          ),
                      ],
                    ),

                    // הוראות ביצוע
                    if (exercise.instructionsHe.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _PreviewSection(
                        title: 'הוראות ביצוע',
                        children: exercise.instructionsHe
                            .asMap()
                            .entries
                            .map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
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
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // כפתורי פעולה
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  onToggleSelect();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? colors.error : colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(isSelected ? Icons.remove : Icons.add),
                label: Text(
                  isSelected ? 'הסר מהרשימה' : 'הוסף לרשימה',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget לסקציה בתצוגה מקדימה
class _PreviewSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PreviewSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.assistant(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

// Widget לשורה בתצוגה מקדימה
class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.w600,
                color: AppTheme.colors.text.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.assistant(
                color: AppTheme.colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// פאנל הפילטרים
class _FilterPanel extends StatelessWidget {
  final List<MuscleGroup> selectedMuscleGroups;
  final List<ExerciseEquipment> selectedEquipment;
  final List<ExerciseDifficulty> selectedDifficulties;
  final List<ExerciseType> selectedTypes;
  final Function(List<MuscleGroup>) onMuscleGroupsChanged;
  final Function(List<ExerciseEquipment>) onEquipmentChanged;
  final Function(List<ExerciseDifficulty>) onDifficultiesChanged;
  final Function(List<ExerciseType>) onTypesChanged;
  final VoidCallback onClearAll;

  const _FilterPanel({
    required this.selectedMuscleGroups,
    required this.selectedEquipment,
    required this.selectedDifficulties,
    required this.selectedTypes,
    required this.onMuscleGroupsChanged,
    required this.onEquipmentChanged,
    required this.onDifficultiesChanged,
    required this.onTypesChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.primary.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'פילטרים',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: Text(
                  'נקה הכל',
                  style: GoogleFonts.assistant(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // קבוצות שרירים
          _FilterSection(
            title: 'קבוצות שרירים',
            items: MuscleGroup.values
                .where((m) => m != MuscleGroup.fullBody)
                .toList(),
            selectedItems: selectedMuscleGroups,
            onChanged: onMuscleGroupsChanged,
            displayName: (item) => item.hebrewName,
            color: (item) => item.color,
          ),

          const SizedBox(height: 16),

          // ציוד
          _FilterSection(
            title: 'ציוד',
            items: ExerciseEquipment.values,
            selectedItems: selectedEquipment,
            onChanged: onEquipmentChanged,
            displayName: (item) => item.hebrewName,
            color: (item) => colors.accent,
          ),
        ],
      ),
    );
  }
}

// סקציית פילטר
class _FilterSection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final List<T> selectedItems;
  final Function(List<T>) onChanged;
  final String Function(T) displayName;
  final Color Function(T) color;

  const _FilterSection({
    required this.title,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.displayName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.assistant(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(
                displayName(item),
                style: GoogleFonts.assistant(
                  color: isSelected ? Colors.white : color(item),
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              selectedColor: color(item),
              backgroundColor: color(item).withOpacity(0.1),
              onSelected: (selected) {
                final newList = List<T>.from(selectedItems);
                if (selected) {
                  newList.add(item);
                } else {
                  newList.remove(item);
                }
                onChanged(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
