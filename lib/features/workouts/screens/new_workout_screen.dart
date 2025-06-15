import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/workout_model.dart';
import '../../../models/exercise.dart';
import '../../../widgets/exercise_form.dart';
import '../../../screens/select_exercises/select_exercises_screen.dart';

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedDifficulty = 'מתחילים';
  String _selectedGoal = 'כוח';
  String _selectedEquipment = 'משקולות';
  final List<ExerciseModel> _exercises = [];
  final _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addExercise(ExerciseModel exercise) {
    setState(() {
      _exercises.add(exercise);
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate() && _exercises.isNotEmpty) {
      final workout = WorkoutModel(
        id: _uuid.v4(),
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        date: DateTime.now(),
        exercises: _exercises,
        metadata: {
          'difficulty': _selectedDifficulty,
          'goal': _selectedGoal,
          'equipment': _selectedEquipment,
          'duration': 45,
        },
      );
      Navigator.pop(context, workout);
    } else if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('נא להוסיף לפחות תרגיל אחד')),
      );
    }
  }

  void _openSelectExercises() async {
    final selected = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SelectExercisesScreen(
          initiallySelected: _exercises
              .map((em) => Exercise(
                    id: em.id,
                    name: em.name,
                    nameHe: em.name,
                    instructions: (em.notes ?? '').split('\n'),
                    instructionsHe: (em.notes ?? '').split('\n'),
                    imageUrl: '',
                    videoUrl: em.videoUrl,
                    metadata: {
                      'mainMuscles': ['כללי'],
                      'secondaryMuscles': <String>[],
                      'muscleGroups': ['כללי'],
                      'type': 'strength',
                    },
                    equipment: em.sets.isNotEmpty ? 'weights' : 'bodyweight',
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null && selected is List) {
      setState(() {
        _exercises.clear();
        _exercises.addAll(selected.map((ex) => ExerciseModel(
              id: ex.id,
              name: ex.nameHe,
              sets: [
                ExerciseSet(
                    id: '${ex.id}_set_1', weight: 0, reps: 10, restTime: 60),
                ExerciseSet(
                    id: '${ex.id}_set_2', weight: 0, reps: 10, restTime: 60),
                ExerciseSet(
                    id: '${ex.id}_set_3', weight: 0, reps: 10, restTime: 60),
              ],
              notes: ex.instructionsHe.join('\n'),
              videoUrl: ex.videoUrl,
            )));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('אימון חדש'),
        backgroundColor: colorScheme.surface,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'שם האימון'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'נא להזין שם לאימון';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'תיאור'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'נא להזין תיאור';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(labelText: 'רמת קושי'),
              items: ['מתחילים', 'בינוני', 'מתקדם']
                  .map((difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGoal,
              decoration: const InputDecoration(labelText: 'מטרה'),
              items: ['כוח', 'סיבולת', 'פיסול', 'מסה']
                  .map((goal) => DropdownMenuItem(
                        value: goal,
                        child: Text(goal),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGoal = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEquipment,
              decoration: const InputDecoration(labelText: 'ציוד'),
              items: ['משקולות', 'מכונות', 'גוף', 'אופניים']
                  .map((equipment) => DropdownMenuItem(
                        value: equipment,
                        child: Text(equipment),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedEquipment = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'תרגילים',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _openSelectExercises,
              icon: const Icon(Icons.list_alt),
              label: const Text('בחר תרגילים מרשימה'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            ..._exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Card(
                child: ListTile(
                  leading:
                      exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty
                          ? const Icon(Icons.play_circle)
                          : const Icon(Icons.fitness_center),
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.sets.length} סטים, ${exercise.sets.firstOrNull?.reps ?? 0} חזרות',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeExercise(index),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            ExerciseForm(
              onSave: _addExercise,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('שמור אימון'),
            ),
          ],
        ),
      ),
    );
  }
}
