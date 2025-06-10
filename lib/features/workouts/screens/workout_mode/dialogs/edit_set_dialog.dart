import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';

class EditSetDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final repsController =
        TextEditingController(text: set.reps?.toString() ?? '10');
    final weightController =
        TextEditingController(text: set.weight?.toString() ?? '0');
    int reps = int.tryParse(repsController.text) ?? 10;
    double weight = double.tryParse(weightController.text) ?? 0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'עריכת סט ${setIdx + 1}',
        style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
      ),
      content: StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('חזרות:', style: GoogleFonts.assistant()),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => setState(() => reps++),
                    ),
                    SizedBox(
                      width: 38,
                      child: Text('$reps',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.assistant(fontSize: 18)),
                    ),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: reps > 1 ? () => setState(() => reps--) : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('משקל (ק"ג):', style: GoogleFonts.assistant()),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: weight > 0
                          ? () => setState(
                              () => weight = (weight - 2.5).clamp(0, 1000))
                          : null,
                    ),
                    SizedBox(
                      width: 48,
                      child: Text('${weight.toStringAsFixed(1)}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.assistant(fontSize: 18)),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () => setState(() => weight += 2.5),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
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
                    onDelete();
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
                    onAdd();
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
            set.reps = reps;
            set.weight = weight;
            onSave(set);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
