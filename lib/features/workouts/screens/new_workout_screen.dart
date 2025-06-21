import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart' as ExerciseLib; // המודל החדש שיצרנו
import '../../../models/exercise_model.dart'
    as WorkoutExercise; // המודל הישן לתרגילים באימון
import '../../../widgets/exercise_form.dart';
import '../../../screens/select_exercises/select_exercises_screen.dart';
import '../../../theme/app_theme.dart';

enum WorkoutDifficulty { beginner, intermediate, advanced }

enum WorkoutGoal { strength, endurance, sculpting, mass, cardio }

enum WorkoutEquipment { weights, machines, bodyweight, cardio, hybrid }

class NewWorkoutScreen extends StatefulWidget {
  final WorkoutModel? editingWorkout;

  const NewWorkoutScreen({
    super.key,
    this.editingWorkout,
  });

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  WorkoutDifficulty _selectedDifficulty = WorkoutDifficulty.beginner;
  WorkoutGoal _selectedGoal = WorkoutGoal.strength;
  WorkoutEquipment _selectedEquipment = WorkoutEquipment.weights;

  final List<WorkoutExercise.ExerciseModel> _exercises = [];
  final _uuid = const Uuid();

  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // אופציות לבחירה
  static const Map<WorkoutDifficulty, String> _difficultyLabels = {
    WorkoutDifficulty.beginner: 'מתחילים',
    WorkoutDifficulty.intermediate: 'בינוני',
    WorkoutDifficulty.advanced: 'מתקדם',
  };

  static const Map<WorkoutGoal, String> _goalLabels = {
    WorkoutGoal.strength: 'כוח',
    WorkoutGoal.endurance: 'סיבולת',
    WorkoutGoal.sculpting: 'פיסול',
    WorkoutGoal.mass: 'מסה',
    WorkoutGoal.cardio: 'אירובי',
  };

  static const Map<WorkoutEquipment, String> _equipmentLabels = {
    WorkoutEquipment.weights: 'משקולות',
    WorkoutEquipment.machines: 'מכונות',
    WorkoutEquipment.bodyweight: 'משקל גוף',
    WorkoutEquipment.cardio: 'אירובי',
    WorkoutEquipment.hybrid: 'מעורב',
  };

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _durationController.text = '45';

    // טעינת נתונים אם במצב עריכה
    if (widget.editingWorkout != null) {
      _loadWorkoutData();
    }

    _animationController.forward();

    // האזנה לשינויים
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _durationController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadWorkoutData() {
    final workout = widget.editingWorkout!;
    _nameController.text = workout.title;
    _descriptionController.text = workout.description ?? '';

    final metadata = workout.metadata;
    if (metadata != null) {
      _selectedDifficulty = _parseDifficulty(metadata['difficulty']);
      _selectedGoal = _parseGoal(metadata['goal']);
      _selectedEquipment = _parseEquipment(metadata['equipment']);
      _durationController.text = (metadata['duration'] ?? 45).toString();
    }

    _exercises.clear();
    // המרה מ-ExerciseModel ל-WorkoutExercise.ExerciseModel
    for (final exercise in workout.exercises) {
      // המרת ExerciseSet מ-WorkoutModel ל-ExerciseModel
      final convertedSets = exercise.sets
          .map((set) => WorkoutExercise.ExerciseSet(
                id: set.id,
                reps: set.reps,
                weight: set.weight,
                restTime: set.restTime,
                isCompleted: set.isCompleted,
                notes: set.notes,
              ))
          .toList();

      _exercises.add(WorkoutExercise.ExerciseModel(
        id: exercise.id,
        name: exercise.name,
        sets: convertedSets,
        notes: exercise.notes,
        restTime: exercise.restTime,
      ));
    }
  }

  WorkoutDifficulty _parseDifficulty(dynamic value) {
    switch (value?.toString()) {
      case 'בינוני':
        return WorkoutDifficulty.intermediate;
      case 'מתקדם':
        return WorkoutDifficulty.advanced;
      default:
        return WorkoutDifficulty.beginner;
    }
  }

  WorkoutGoal _parseGoal(dynamic value) {
    switch (value?.toString()) {
      case 'סיבולת':
        return WorkoutGoal.endurance;
      case 'פיסול':
        return WorkoutGoal.sculpting;
      case 'מסה':
        return WorkoutGoal.mass;
      case 'אירובי':
        return WorkoutGoal.cardio;
      default:
        return WorkoutGoal.strength;
    }
  }

  WorkoutEquipment _parseEquipment(dynamic value) {
    switch (value?.toString()) {
      case 'מכונות':
        return WorkoutEquipment.machines;
      case 'משקל גוף':
        return WorkoutEquipment.bodyweight;
      case 'אירובי':
        return WorkoutEquipment.cardio;
      case 'מעורב':
        return WorkoutEquipment.hybrid;
      default:
        return WorkoutEquipment.weights;
    }
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  void _addExercise(WorkoutExercise.ExerciseModel exercise) {
    setState(() {
      _exercises.add(exercise);
      _hasUnsavedChanges = true;
    });

    // אנימציה עדינה
    HapticFeedback.lightImpact();
  }

  void _removeExercise(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'מחיקת תרגיל',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'האם אתה בטוח שברצונך למחוק את התרגיל "${_exercises[index].name}"?',
          style: GoogleFonts.assistant(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ביטול', style: GoogleFonts.assistant()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _exercises.removeAt(index);
                _hasUnsavedChanges = true;
              });
              HapticFeedback.lightImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.error,
            ),
            child: Text(
              'מחק',
              style: GoogleFonts.assistant(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    if (_exercises.isEmpty) {
      _showErrorSnackBar('נא להוסיף לפחות תרגיל אחד');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final duration = int.tryParse(_durationController.text) ?? 45;

      final workout = WorkoutModel(
        id: widget.editingWorkout?.id ?? _uuid.v4(),
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.editingWorkout?.createdAt ?? DateTime.now(),
        date: DateTime.now(),
        exercises: _exercises
            .map((exercise) => ExerciseModel(
                  id: exercise.id,
                  name: exercise.name,
                  sets: exercise.sets
                      .map((set) => ExerciseSet(
                            id: set.id,
                            reps: set.reps,
                            weight: set.weight,
                            restTime: set.restTime,
                            isCompleted: set.isCompleted,
                            notes: set.notes,
                          ))
                      .toList(),
                  notes: exercise.notes,
                  restTime: exercise.restTime,
                ))
            .toList(),
        metadata: {
          'difficulty': _difficultyLabels[_selectedDifficulty],
          'goal': _goalLabels[_selectedGoal],
          'equipment': _equipmentLabels[_selectedEquipment],
          'duration': duration,
          'exerciseCount': _exercises.length,
          'totalSets':
              _exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length),
        },
      );

      // המתנה קצרה לאנימציה
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context, workout);
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת האימון: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.assistant(),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openSelectExercises() async {
    final selected =
        await Navigator.of(context).push<List<ExerciseLib.Exercise>>(
      MaterialPageRoute(
        builder: (_) => SelectExercisesScreen(
          initiallySelected: _exercises
              .map((em) => ExerciseLib.Exercise(
                    id: em.id,
                    name: em.name,
                    nameHe: em.name,
                    description: em.notes ?? '',
                    descriptionHe: em.notes ?? '',
                    instructions: (em.notes ?? '').split('\n'),
                    instructionsHe: (em.notes ?? '').split('\n'),
                    type: ExerciseLib.ExerciseType.strength,
                    equipment: ExerciseLib.ExerciseEquipment.bodyweight,
                    difficulty: ExerciseLib.ExerciseDifficulty.medium,
                    primaryMuscles: [ExerciseLib.MuscleGroup.chest],
                    secondaryMuscles: [],
                  ))
              .toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _exercises.clear();
        _exercises.addAll(selected.map((ex) => WorkoutExercise.ExerciseModel(
              id: ex.id,
              name: ex.nameHe,
              sets: _generateDefaultSets(ex.id),
              notes: ex.instructionsHe.join('\n'),
            )));
        _hasUnsavedChanges = true;
      });
    }
  }

  List<WorkoutExercise.ExerciseSet> _generateDefaultSets(String exerciseId) {
    final defaultReps = _getDefaultRepsForGoal();
    final defaultRest = _getDefaultRestForGoal();

    return List.generate(
      3,
      (index) => WorkoutExercise.ExerciseSet(
        id: '${exerciseId}_set_${index + 1}',
        weight: 0,
        reps: defaultReps,
        restTime: defaultRest,
      ),
    );
  }

  int _getDefaultRepsForGoal() {
    switch (_selectedGoal) {
      case WorkoutGoal.strength:
        return 6;
      case WorkoutGoal.mass:
        return 8;
      case WorkoutGoal.endurance:
        return 15;
      case WorkoutGoal.sculpting:
        return 12;
      case WorkoutGoal.cardio:
        return 20;
    }
  }

  int _getDefaultRestForGoal() {
    switch (_selectedGoal) {
      case WorkoutGoal.strength:
        return 180; // 3 דקות
      case WorkoutGoal.mass:
        return 120; // 2 דקות
      case WorkoutGoal.endurance:
        return 45;
      case WorkoutGoal.sculpting:
        return 60;
      case WorkoutGoal.cardio:
        return 30;
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.colors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'שמירת שינויים',
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'יש לך שינויים שלא נשמרו. האם תרצה לשמור אותם?',
              style: GoogleFonts.assistant(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('יציאה בלי שמירה', style: GoogleFonts.assistant()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  _saveWorkout();
                },
                child: Text('שמור ויציאה', style: GoogleFonts.assistant()),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _updateExistingSetsForGoal() {
    final newReps = _getDefaultRepsForGoal();
    final newRest = _getDefaultRestForGoal();

    // יצירת רשימת תרגילים חדשה עם הסטים המעודכנים
    final updatedExercises = <WorkoutExercise.ExerciseModel>[];

    for (var exercise in _exercises) {
      // יצירת סטים חדשים עם הערכים החדשים
      final updatedSets = exercise.sets.map((oldSet) {
        return WorkoutExercise.ExerciseSet(
          id: oldSet.id,
          weight: oldSet.weight,
          reps: newReps,
          restTime: newRest,
          isCompleted: oldSet.isCompleted,
          notes: oldSet.notes,
        );
      }).toList();

      // יצירת תרגיל חדש עם הסטים המעודכנים
      final updatedExercise = WorkoutExercise.ExerciseModel(
        id: exercise.id,
        name: exercise.name,
        sets: updatedSets,
        notes: exercise.notes,
        restTime: exercise.restTime,
      );

      updatedExercises.add(updatedExercise);
    }

    // החלפת הרשימה המקורית
    _exercises.clear();
    _exercises.addAll(updatedExercises);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final isEditing = widget.editingWorkout != null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(
            isEditing ? 'עריכת אימון' : 'אימון חדש',
            style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
          ),
          backgroundColor: colors.surface,
          elevation: 0,
          actions: [
            if (_hasUnsavedChanges)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'לא נשמר',
                  style: GoogleFonts.assistant(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildWorkoutParametersSection(),
                const SizedBox(height: 24),
                _buildExercisesSection(),
                const SizedBox(height: 24),
                _buildSaveButton(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final colors = AppTheme.colors;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'פרטי האימון',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.headline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'שם האימון',
                labelStyle: GoogleFonts.assistant(),
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surface,
              ),
              style: GoogleFonts.assistant(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'נא להזין שם לאימון';
                }
                if (value.trim().length < 3) {
                  return 'שם האימון חייב להכיל לפחות 3 תווים';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'תיאור (אופציונלי)',
                labelStyle: GoogleFonts.assistant(),
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surface,
              ),
              style: GoogleFonts.assistant(),
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: 'משך זמן משוער (דקות)',
                labelStyle: GoogleFonts.assistant(),
                prefixIcon: const Icon(Icons.timer_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.surface,
                suffixText: 'דקות',
              ),
              style: GoogleFonts.assistant(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                final duration = int.tryParse(value ?? '');
                if (duration == null || duration < 5) {
                  return 'נא להזין משך זמן תקין (לפחות 5 דקות)';
                }
                if (duration > 300) {
                  return 'משך זמן מקסימלי: 300 דקות';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutParametersSection() {
    final colors = AppTheme.colors;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'פרמטרים',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.headline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdown<WorkoutDifficulty>(
              label: 'רמת קושי',
              icon: Icons.trending_up,
              value: _selectedDifficulty,
              items: WorkoutDifficulty.values,
              itemLabels: _difficultyLabels,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value;
                  _hasUnsavedChanges = true;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown<WorkoutGoal>(
              label: 'מטרה',
              icon: Icons.flag_outlined,
              value: _selectedGoal,
              items: WorkoutGoal.values,
              itemLabels: _goalLabels,
              onChanged: (value) {
                setState(() {
                  _selectedGoal = value;
                  _hasUnsavedChanges = true;
                  // עדכון סטים קיימים לפי המטרה החדשה
                  _updateExistingSetsForGoal();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown<WorkoutEquipment>(
              label: 'ציוד',
              icon: Icons.sports_gymnastics,
              value: _selectedEquipment,
              items: WorkoutEquipment.values,
              itemLabels: _equipmentLabels,
              onChanged: (value) {
                setState(() {
                  _selectedEquipment = value;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required Map<T, String> itemLabels,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.assistant(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: AppTheme.colors.surface,
      ),
      style: GoogleFonts.assistant(color: AppTheme.colors.text),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabels[item] ?? '',
                  style: GoogleFonts.assistant(),
                ),
              ))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }

  Widget _buildExercisesSection() {
    final colors = AppTheme.colors;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'תרגילים',
                      style: GoogleFonts.assistant(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.headline,
                      ),
                    ),
                  ],
                ),
                if (_exercises.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_exercises.length}',
                      style: GoogleFonts.assistant(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // כפתורי הוספת תרגילים
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openSelectExercises,
                    icon: const Icon(Icons.search),
                    label: Text(
                      'בחר מרשימה',
                      style: GoogleFonts.assistant(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // הוספת תרגיל ידני
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: colors.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: ExerciseForm(onSave: (exercise) {
                            // המרה מ-ExerciseModel (workout_model) ל-WorkoutExercise.ExerciseModel
                            final convertedExercise =
                                WorkoutExercise.ExerciseModel(
                              id: exercise.id,
                              name: exercise.name,
                              sets: exercise.sets
                                  .map((set) => WorkoutExercise.ExerciseSet(
                                        id: set.id,
                                        reps: set.reps,
                                        weight: set.weight,
                                        restTime: set.restTime,
                                        isCompleted: set.isCompleted,
                                        notes: set.notes,
                                      ))
                                  .toList(),
                              notes: exercise.notes,
                              restTime: exercise.restTime,
                            );
                            _addExercise(convertedExercise);
                          }),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      'הוסף ידני',
                      style: GoogleFonts.assistant(),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // רשימת תרגילים
            if (_exercises.isEmpty)
              _buildEmptyExercisesState()
            else
              _buildExercisesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExercisesState() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: colors.text.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'אין תרגילים עדיין',
            style: GoogleFonts.assistant(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.text.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'הוסף תרגילים כדי להתחיל לבנות את האימון שלך',
            style: GoogleFonts.assistant(
              color: colors.text.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exercises.length,
      onReorder: _reorderExercises,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return _buildExerciseCard(exercise, index);
      },
    );
  }

  Widget _buildExerciseCard(WorkoutExercise.ExerciseModel exercise, int index) {
    final colors = AppTheme.colors;

    return Card(
      key: ValueKey(exercise.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
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
            const SizedBox(width: 8),
            Icon(
              Icons.fitness_center,
              color: colors.primary,
            ),
          ],
        ),
        title: Text(
          exercise.name,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.w600,
            color: colors.headline,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${exercise.sets.length} סטים • ${exercise.sets.isNotEmpty ? exercise.sets.first.reps : 0} חזרות',
              style: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.7),
              ),
            ),
            if (exercise.notes?.isNotEmpty == true)
              Text(
                exercise.notes!.length > 50
                    ? '${exercise.notes!.substring(0, 50)}...'
                    : exercise.notes!,
                style: GoogleFonts.assistant(
                  fontSize: 12,
                  color: colors.text.withOpacity(0.5),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: colors.text.withOpacity(0.5)),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: colors.error,
              onPressed: () => _removeExercise(index),
              tooltip: 'מחק תרגיל',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final colors = AppTheme.colors;

    return ElevatedButton(
      onPressed: _isLoading ? null : _saveWorkout,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
      ),
      child: _isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'שומר...',
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save),
                const SizedBox(width: 8),
                Text(
                  widget.editingWorkout != null ? 'עדכן אימון' : 'שמור אימון',
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
