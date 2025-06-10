import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise_model.dart';
import '../providers/workouts_provider.dart';
import 'dialogs/add_exercise_dialog.dart';

class NewWorkoutScreen extends StatefulWidget {
  final WorkoutModel? workout;

  const NewWorkoutScreen({
    super.key,
    this.workout,
  });

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<ExerciseModel> _exercises = [];
  bool _isTemplate = false;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _titleController.text = widget.workout!.title;
      _descriptionController.text = widget.workout!.description ?? '';
      _exercises = List.from(widget.workout!.exercises);
      _isTemplate = widget.workout!.isTemplate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final isEditing = widget.workout != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'ערוך אימון' : 'אימון חדש',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
              color: colors.error,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildExercisesList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasicInfo() {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'מידע בסיסי',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'שם האימון',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'אנא הכנס שם לאימון';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'תיאור (אופציונלי)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            'שמור כתבנית',
            style: GoogleFonts.assistant(
              color: colors.headline,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'תבנית מאפשרת לך ליצור אימונים חדשים בקלות',
            style: GoogleFonts.assistant(
              color: colors.headline.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          value: _isTemplate,
          onChanged: (value) => setState(() => _isTemplate = value),
          activeColor: colors.primary,
        ),
      ],
    );
  }

  Widget _buildExercisesList() {
    final colors = AppTheme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'תרגילים',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.headline,
              ),
            ),
            TextButton.icon(
              onPressed: _showAddExerciseDialog,
              icon: const Icon(Icons.add),
              label: const Text('הוסף תרגיל'),
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_exercises.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: colors.headline.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'אין תרגילים באימון',
                    style: GoogleFonts.assistant(
                      color: colors.headline.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'הוסף תרגילים כדי להתחיל',
                    style: GoogleFonts.assistant(
                      color: colors.headline.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exercises.length,
            onReorder: _reorderExercises,
            itemBuilder: (context, index) {
              final exercise = _exercises[index];
              return _ExerciseCard(
                key: ValueKey(exercise.id),
                exercise: exercise,
                onEdit: () => _editExercise(index),
                onDelete: () => _deleteExercise(index),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final colors = AppTheme.colors;
    final provider = context.read<WorkoutsProvider>();
    final isEditing = widget.workout != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _saveWorkout(provider),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isEditing ? 'שמור שינויים' : 'צור אימון',
            style: GoogleFonts.assistant(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExerciseDialog() async {
    final result = await showDialog<ExerciseModel>(
      context: context,
      builder: (context) => const AddExerciseDialog(),
    );

    if (result != null) {
      setState(() {
        _exercises.add(result);
      });
    }
  }

  void _editExercise(int index) async {
    final result = await showDialog<ExerciseModel>(
      context: context,
      builder: (context) => AddExerciseDialog(
        exercise: _exercises[index],
      ),
    );

    if (result != null) {
      setState(() {
        _exercises[index] = result;
      });
    }
  }

  void _deleteExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _exercises.removeAt(oldIndex);
      _exercises.insert(newIndex, exercise);
    });
  }

  void _showDeleteConfirmation() {
    final colors = AppTheme.colors;
    final provider = context.read<WorkoutsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'מחק אימון',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        content: const Text('האם אתה בטוח שברצונך למחוק את האימון?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteWorkout(widget.workout!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.error,
            ),
            child: const Text('מחק'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkout(WorkoutsProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('אנא הוסף לפחות תרגיל אחד לאימון'),
        ),
      );
      return;
    }

    final workout = WorkoutModel(
      id: widget.workout?.id ?? '',
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      exercises: _exercises,
      createdAt: widget.workout?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      userId: widget.workout?.userId,
      isTemplate: _isTemplate,
    );

    await provider.saveWorkout(workout);
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required Key key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.fitness_center, color: colors.primary),
        title: Text(
          exercise.name,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            color: colors.headline,
          ),
        ),
        subtitle: Text(
          '${exercise.sets.length} סטים',
          style: GoogleFonts.assistant(
            color: colors.headline.withOpacity(0.7),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: colors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: colors.error,
            ),
            Icon(
              Icons.drag_handle,
              color: colors.headline.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
