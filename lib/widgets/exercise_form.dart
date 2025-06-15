// lib/widgets/exercise_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_model.dart';

class ExerciseForm extends StatefulWidget {
  final Function(ExerciseModel) onSave;
  final ExerciseModel? initialExercise;

  const ExerciseForm({
    super.key,
    required this.onSave,
    this.initialExercise,
  });

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _notesController;

  // Focus nodes for field navigation
  final _nameFocus = FocusNode();
  final _setsFocus = FocusNode();
  final _repsFocus = FocusNode();
  final _notesFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialExercise?.name ?? '');
    _setsController = TextEditingController(
        text: widget.initialExercise?.sets.length.toString() ?? '1');
    _repsController = TextEditingController(
        text: widget.initialExercise?.sets.isNotEmpty == true
            ? widget.initialExercise!.sets.first.reps?.toString() ?? '1'
            : '1');
    _notesController =
        TextEditingController(text: widget.initialExercise?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    _nameFocus.dispose();
    _setsFocus.dispose();
    _repsFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      try {
        final exercise = ExerciseModel(
          id: widget.initialExercise?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          sets: List.generate(
            int.parse(_setsController.text),
            (index) => ExerciseSet(
              id: '${DateTime.now().millisecondsSinceEpoch}_$index',
              weight: 0,
              reps: int.parse(_repsController.text),
            ),
          ),
          notes: _notesController.text,
        );
        widget.onSave(exercise);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialExercise == null
                  ? 'התרגיל נוסף בהצלחה'
                  : 'התרגיל עודכן בהצלחה',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // ניקוי שדות אם זה תרגיל חדש
        if (widget.initialExercise == null) {
          _nameController.clear();
          _setsController.text = '1';
          _repsController.text = '1';
          _notesController.clear();
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: 'שם התרגיל',
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_setsFocus),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'נא להזין שם תרגיל';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      focusNode: _setsFocus,
                      decoration: const InputDecoration(
                        labelText: 'מספר סטים',
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_repsFocus),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין מספר סטים';
                        }
                        if (int.tryParse(value) == null) {
                          return 'נא להזין מספר תקין';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      focusNode: _repsFocus,
                      decoration: const InputDecoration(
                        labelText: 'מספר חזרות',
                        prefixIcon: Icon(Icons.repeat_one),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_notesFocus),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין מספר חזרות';
                        }
                        if (int.tryParse(value) == null) {
                          return 'נא להזין מספר תקין';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                focusNode: _notesFocus,
                decoration: const InputDecoration(
                  labelText: 'הערות',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _saveExercise(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveExercise,
                icon: Icon(
                  widget.initialExercise == null
                      ? Icons.add_circle_outline
                      : Icons.save_outlined,
                ),
                label: Text(
                  widget.initialExercise == null ? 'הוסף תרגיל' : 'עדכן תרגיל',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
