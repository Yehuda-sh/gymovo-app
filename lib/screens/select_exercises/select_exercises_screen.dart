// lib/screens/select_exercises/select_exercises_screen.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/exercise.dart';
import '../../services/exercise_image_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'exercise_image_picker_screen.dart';

class SelectExercisesScreen extends StatefulWidget {
  final List<Exercise> initiallySelected;
  const SelectExercisesScreen({super.key, this.initiallySelected = const []});

  @override
  State<SelectExercisesScreen> createState() => _SelectExercisesScreenState();
}

class _SelectExercisesScreenState extends State<SelectExercisesScreen>
    with SingleTickerProviderStateMixin {
  List<Exercise> _exercises = [];
  Set<String> _selectedIds = {};
  String _search = '';
  bool _isLoading = true;
  String? _error;
  Map<String, String> _exerciseImages = {};
  bool _showImages = true;

  // פילטרים
  String? _selectedDifficulty;
  String? _selectedEquipment;
  Set<String> _selectedMuscleGroups = {};
  late TabController _tabController;

  // קטגוריות של קבוצות שרירים
  final List<String> _muscleCategories = [
    'הכל',
    'רגליים',
    'חזה',
    'גב',
    'כתפיים',
    'ידיים',
    'בטן',
    'ישבן',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initiallySelected.map((e) => e.id).toSet();
    _tabController =
        TabController(length: _muscleCategories.length, vsync: this);
    _loadExercises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data =
          await rootBundle.loadString('assets/data/workout_exercises.json');
      final List<dynamic> jsonList = json.decode(data);
      final exercises =
          jsonList.map((json) => Exercise.fromJson(json)).toList();

      // הצג את התרגילים מיד
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

  Future<void> _loadExerciseImagesInBackground(List<Exercise> exercises) async {
    for (final exercise in exercises) {
      String imageUrl = '';

      // נסה להשתמש בתמונה הקיימת
      if (exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty) {
        imageUrl = exercise.imageUrl!;
      } else {
        // נסה ליצור URL מותאם
        imageUrl = ExerciseImageService.getExerciseImageUrl(
          exercise.nameEn ?? exercise.nameHe,
        );
      }

      // בדוק אם התמונה תקינה (רק אם זה URL מהאינטרנט)
      if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
        try {
          final isValid = await ExerciseImageService.isImageUrlValid(imageUrl);
          if (!isValid) {
            // השתמש בתמונת ברירת מחדל
            final mainMuscle = exercise.mainMuscles?.firstOrNull ?? '';
            imageUrl = ExerciseImageService.getDefaultExerciseImage(
              exercise.type ?? 'strength',
              mainMuscle,
            );
          }
        } catch (e) {
          // אם יש שגיאה, השתמש בתמונת ברירת מחדל
          final mainMuscle = exercise.mainMuscles?.firstOrNull ?? '';
          imageUrl = ExerciseImageService.getDefaultExerciseImage(
            exercise.type ?? 'strength',
            mainMuscle,
          );
        }
      } else if (imageUrl.isEmpty) {
        // אם אין תמונה, השתמש בתמונת ברירת מחדל
        final mainMuscle = exercise.mainMuscles?.firstOrNull ?? '';
        imageUrl = ExerciseImageService.getDefaultExerciseImage(
          exercise.type ?? 'strength',
          mainMuscle,
        );
      }

      // עדכן את התמונה בממשק
      if (mounted) {
        setState(() {
          _exerciseImages[exercise.id] = imageUrl;
        });
      }
    }
  }

  List<Exercise> get _filteredExercises {
    return _exercises.where((e) {
      // פילטור לפי חיפוש
      final matchesSearch = _search.isEmpty ||
          e.nameHe.toLowerCase().contains(_search.toLowerCase()) ||
          (e.mainMuscles?.any(
                  (m) => m.toLowerCase().contains(_search.toLowerCase())) ==
              true);

      // פילטור לפי רמת קושי
      final matchesDifficulty =
          _selectedDifficulty == null || e.difficulty == _selectedDifficulty;

      // פילטור לפי ציוד
      final matchesEquipment =
          _selectedEquipment == null || e.equipment == _selectedEquipment;

      // פילטור לפי קבוצת שרירים
      final matchesMuscleGroup = _selectedMuscleGroups.isEmpty ||
          (e.mainMuscles?.any((m) => _selectedMuscleGroups.contains(m)) ??
              false);

      // פילטור לפי הקטגוריה הנבחרת
      final selectedCategory = _muscleCategories[_tabController.index];
      final matchesCategory = selectedCategory == 'הכל' ||
          (e.mainMuscles
                  ?.any((m) => _getMuscleCategory(m) == selectedCategory) ??
              false);

      return matchesSearch &&
          matchesDifficulty &&
          matchesEquipment &&
          matchesMuscleGroup &&
          matchesCategory;
    }).toList();
  }

  String _getMuscleCategory(String muscle) {
    // ממיר שם שריר לקטגוריה
    final muscleToCategory = {
      'Quadriceps': 'רגליים',
      'Hamstrings': 'רגליים',
      'Calves': 'רגליים',
      'Chest': 'חזה',
      'Back': 'גב',
      'Shoulders': 'כתפיים',
      'Biceps': 'ידיים',
      'Triceps': 'ידיים',
      'Abdominals': 'בטן',
      'Core': 'בטן',
      'Glutes': 'ישבן',
    };
    return muscleToCategory[muscle] ?? 'אחר';
  }

  void _toggleSelect(Exercise exercise) {
    setState(() {
      if (_selectedIds.contains(exercise.id)) {
        _selectedIds.remove(exercise.id);
      } else {
        _selectedIds.add(exercise.id);
      }
    });
  }

  Widget _buildExerciseImage(Exercise exercise) {
    final imageUrl = _exerciseImages[exercise.id] ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = imageUrl.isEmpty;

    return GestureDetector(
      onTap: () => _showExercisePreview(exercise),
      child: Stack(
        children: [
          if (isLoading)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (imageUrl.startsWith('assets/'))
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
            ),

          // כפתור בחירת תמונה (רק אם התמונה נטענה)
          if (!isLoading)
            Positioned(
              bottom: -2,
              right: -2,
              child: GestureDetector(
                onTap: () => _showImagePicker(exercise),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.surface, width: 1),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 12,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showExercisePreview(Exercise exercise) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = _exerciseImages[exercise.id] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // כותרת
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.nameHe,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // תוכן
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // תמונה
                      if (imageUrl.isNotEmpty)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    imageUrl,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 200,
                                      color: colorScheme.surfaceVariant,
                                      child: Icon(
                                        Icons.fitness_center,
                                        size: 48,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // פרטי התרגיל
                      if (exercise.equipment != null ||
                          exercise.difficulty != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (exercise.equipment != null)
                              _buildInfoChip(
                                Icons.fitness_center,
                                exercise.equipment!,
                                colorScheme.primaryContainer,
                              ),
                            if (exercise.difficulty != null)
                              _buildInfoChip(
                                Icons.speed,
                                exercise.difficulty!,
                                _getDifficultyColor(exercise.difficulty!)
                                    .withOpacity(0.1),
                                textColor: _getDifficultyColor(
                                  exercise.difficulty!,
                                ),
                              ),
                          ],
                        ),

                      if (exercise.mainMuscles?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        Text(
                          'שרירים עיקריים:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: exercise.mainMuscles!
                              .map(
                                (muscle) => _buildInfoChip(
                                  Icons.accessibility_new,
                                  muscle,
                                  colorScheme.secondaryContainer,
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      if (exercise.instructionsHe.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'הוראות ביצוע:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.instructionsHe.join('\n'),
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // כפתורי פעולה
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _toggleSelect(exercise);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      _selectedIds.contains(exercise.id)
                          ? 'הסר מהרשימה'
                          : 'הוסף לרשימה',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color backgroundColor,
      {Color? textColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor ?? colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImagePicker(Exercise exercise) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ExerciseImagePickerScreen(
          exerciseName: exercise.nameHe,
          exerciseType: exercise.type ?? 'strength',
          mainMuscle: exercise.mainMuscles?.firstOrNull ?? '',
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // צ'יפ לבחירת רמת קושי
          FilterChip(
            label: Text(_selectedDifficulty ?? 'רמת קושי'),
            selected: _selectedDifficulty != null,
            onSelected: (selected) {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildDifficultyPicker(),
              );
            },
          ),
          const SizedBox(width: 8),

          // צ'יפ לבחירת ציוד
          FilterChip(
            label: Text(_selectedEquipment ?? 'ציוד'),
            selected: _selectedEquipment != null,
            onSelected: (selected) {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildEquipmentPicker(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyPicker() {
    final difficulties = ['קל', 'בינוני', 'מתקדם'];
    return ListView.builder(
      shrinkWrap: true,
      itemCount: difficulties.length,
      itemBuilder: (context, index) {
        final difficulty = difficulties[index];
        return ListTile(
          title: Text(difficulty),
          selected: _selectedDifficulty == difficulty,
          onTap: () {
            setState(() {
              _selectedDifficulty =
                  _selectedDifficulty == difficulty ? null : difficulty;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildEquipmentPicker() {
    final equipment = ['ללא ציוד', 'משקוליות', 'מכונה', 'מוט אולימפי'];
    return ListView.builder(
      shrinkWrap: true,
      itemCount: equipment.length,
      itemBuilder: (context, index) {
        final equip = equipment[index];
        return ListTile(
          title: Text(equip),
          selected: _selectedEquipment == equip,
          onTap: () {
            setState(() {
              _selectedEquipment = _selectedEquipment == equip ? null : equip;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('בחר תרגילים'),
        actions: [
          IconButton(
            icon: Icon(_showImages ? Icons.image_not_supported : Icons.image),
            onPressed: () {
              setState(() {
                _showImages = !_showImages;
              });
            },
            tooltip: _showImages ? 'הסתר תמונות' : 'הצג תמונות',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
            tooltip: 'רענן',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs:
              _muscleCategories.map((category) => Tab(text: category)).toList(),
          onTap: (index) {
            setState(() {}); // רענון הרשימה כשמשתנה הקטגוריה
          },
        ),
      ),
      body: Column(
        children: [
          // חיפוש
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'חפש תרגיל או שריר...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),

          // פילטרים
          _buildFilterChips(),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (_error != null)
            Expanded(
                child: Center(child: Text('שגיאה בטעינת תרגילים: $_error'))),
          if (!_isLoading && _error == null)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  final selected = _selectedIds.contains(exercise.id);

                  return Card(
                    color: selected
                        ? colorScheme.primary.withOpacity(0.08)
                        : colorScheme.surface,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: selected ? 2 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: selected
                            ? colorScheme.primary.withOpacity(0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      leading:
                          _showImages ? _buildExerciseImage(exercise) : null,
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.nameHe,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (exercise.difficulty != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(exercise.difficulty!)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                exercise.difficulty!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _getDifficultyColor(exercise.difficulty!),
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              if (exercise.equipment != null)
                                _buildChip(
                                    exercise.equipment!, Icons.fitness_center),
                              ...(exercise.mainMuscles ?? []).map(
                                (muscle) =>
                                    _buildChip(muscle, Icons.accessibility_new),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Checkbox(
                        value: selected,
                        onChanged: (_) => _toggleSelect(exercise),
                        activeColor: colorScheme.primary,
                      ),
                      onTap: () => _toggleSelect(exercise),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final selectedExercises =
              _exercises.where((e) => _selectedIds.contains(e.id)).toList();
          Navigator.of(context).pop(selectedExercises);
        },
        label: const Text('הוסף'),
        icon: const Icon(Icons.check),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'קל':
        return Colors.green;
      case 'בינוני':
        return Colors.orange;
      case 'מתקדם':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
