import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/exercise_history.dart';
import '../../../providers/exercise_history_provider.dart';
import 'package:provider/provider.dart';

class ExerciseSetForm extends StatefulWidget {
  final Function(ExerciseSet) onSave;
  final ExerciseSet? existingSet;
  final String exerciseId;

  const ExerciseSetForm({
    Key? key,
    required this.onSave,
    required this.exerciseId,
    this.existingSet,
  }) : super(key: key);

  @override
  State<ExerciseSetForm> createState() => _ExerciseSetFormState();
}

class _ExerciseSetFormState extends State<ExerciseSetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _notesController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
        text: widget.existingSet?.weight.toString() ?? '');
    _repsController =
        TextEditingController(text: widget.existingSet?.reps.toString() ?? '');
    _notesController =
        TextEditingController(text: widget.existingSet?.notes ?? '');
    _isCompleted = widget.existingSet?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final set = ExerciseSet(
        id: widget.existingSet?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        exerciseId: widget.exerciseId,
        weight: double.parse(_weightController.text),
        reps: int.parse(_repsController.text),
        notes: _notesController.text,
        isCompleted: _isCompleted,
        date: widget.existingSet?.date ?? DateTime.now(),
        createdAt: widget.existingSet?.createdAt,
      );
      widget.onSave(set);

      if (widget.existingSet == null) {
        _weightController.clear();
        _repsController.clear();
        _notesController.clear();
        _isCompleted = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existingSet == null ? 'הוספת סט חדש' : 'עריכת סט',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'משקל (ק"ג)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'נא להזין משקל';
                        }
                        if (double.tryParse(value) == null) {
                          return 'נא להזין מספר תקין';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      decoration: const InputDecoration(
                        labelText: 'חזרות',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'הערות',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('הסט הושלם'),
                value: _isCompleted,
                onChanged: (value) => setState(() => _isCompleted = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _handleSubmit,
                icon: Icon(widget.existingSet == null ? Icons.add : Icons.save),
                label: Text(
                    widget.existingSet == null ? 'הוסף סט' : 'שמור שינויים'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
