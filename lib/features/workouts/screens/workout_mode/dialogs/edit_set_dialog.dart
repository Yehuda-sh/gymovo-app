// lib/features/workouts/screens/workout_mode/dialogs/edit_set_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';

class EditSetDialog extends StatefulWidget {
  final String exId;
  final int setIdx;
  final dynamic set;
  final Function(dynamic) onSave;
  final Function() onDelete;
  final Function() onAdd;

  const EditSetDialog({
    super.key,
    required this.exId,
    required this.setIdx,
    required this.set,
    required this.onSave,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<EditSetDialog> createState() => _EditSetDialogState();
}

class _EditSetDialogState extends State<EditSetDialog> {
  late int reps;
  late double weight;

  late TextEditingController repsController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    reps = widget.set.reps ?? 10;
    weight = widget.set.weight?.toDouble() ?? 0.0;

    repsController = TextEditingController(text: reps.toString());
    weightController = TextEditingController(text: weight.toStringAsFixed(1));

    repsController.addListener(() {
      final value = int.tryParse(repsController.text);
      if (value != null && value > 0) {
        setState(() {
          reps = value;
        });
      }
    });

    weightController.addListener(() {
      final value = double.tryParse(weightController.text);
      if (value != null && value >= 0) {
        setState(() {
          weight = value;
        });
      }
    });
  }

  @override
  void dispose() {
    repsController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _changeReps(int delta) {
    final newValue = (reps + delta).clamp(1, 9999);
    setState(() {
      reps = newValue;
      repsController.text = reps.toString();
    });
  }

  void _changeWeight(double delta) {
    final newValue = (weight + delta).clamp(0.0, 9999.0);
    setState(() {
      weight = newValue;
      weightController.text = weight.toStringAsFixed(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'עריכת סט ${widget.setIdx + 1}',
        style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // חזרות
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('חזרות:', style: GoogleFonts.assistant()),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _changeReps(1),
                    ),
                    SizedBox(
                      width: 38,
                      child: TextField(
                        controller: repsController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.assistant(fontSize: 18),
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: reps > 1 ? () => _changeReps(-1) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // משקל
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('משקל (ק"ג):', style: GoogleFonts.assistant()),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: weight > 0 ? () => _changeWeight(-2.5) : null,
                    ),
                    SizedBox(
                      width: 48,
                      child: TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.assistant(fontSize: 18),
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => _changeWeight(2.5),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // כפתורים למחיקה והוספה
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.delete, color: Colors.red[400]),
                  label: Text('מחק סט',
                      style: GoogleFonts.assistant(color: Colors.red[400])),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.05),
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                  onPressed: () {
                    widget.onDelete();
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: Icon(Icons.add, color: Colors.blue),
                  label: Text('הוסף סט',
                      style: GoogleFonts.assistant(color: Colors.blue)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.07),
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  onPressed: () {
                    widget.onAdd();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('ביטול'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.colors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('שמור',
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold)),
          onPressed: () {
            widget.set.reps = reps;
            widget.set.weight = weight;
            widget.onSave(widget.set);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
