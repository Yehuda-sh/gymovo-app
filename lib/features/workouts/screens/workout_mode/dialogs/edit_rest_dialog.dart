// lib/features/workouts/screens/workout_mode/dialogs/edit_rest_dialog.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../widgets/rest_time_button.dart';

class EditRestDialog extends StatefulWidget {
  final String exId;
  final int initialRest;
  final Function(int) onSave;

  const EditRestDialog({
    super.key,
    required this.exId,
    required this.initialRest,
    required this.onSave,
  });

  @override
  State<EditRestDialog> createState() => _EditRestDialogState();
}

class _EditRestDialogState extends State<EditRestDialog> {
  late int restTime;
  late TextEditingController controller;

  final int defaultRest = 60;
  final int minRest = 0;
  final int maxRest = 600;

  final Color colorMain = AppTheme.colors.primary;
  final Color colorAccent = AppTheme.colors.accent;

  @override
  void initState() {
    super.initState();
    restTime = widget.initialRest;
    controller = TextEditingController(text: restTime.toString());
    controller.addListener(() {
      final parsed = int.tryParse(controller.text);
      if (parsed != null && parsed >= minRest && parsed <= maxRest) {
        setState(() {
          restTime = parsed;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _updateRestTime(int delta) {
    final newRest = (restTime + delta).clamp(minRest, maxRest);
    setState(() {
      restTime = newRest;
      controller.text = restTime.toString();
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.only(top: 18),
      title: Center(
        child: Column(
          children: [
            Semantics(
              label: 'טיימר',
              child: Icon(Icons.timer, size: 56, color: colorMain),
            ),
            const SizedBox(height: 6),
            Text(
              'עריכת זמן מנוחה',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: AppTheme.colors.headline,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'כמה זמן לנוח בין הסטים?',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppTheme.colors.text.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ברירת המחדל: $defaultRest שניות. ניתן לשנות או לאפס.',
            style: GoogleFonts.assistant(fontSize: 13, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (restTime == 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: 'סופר סט',
                  child: Icon(Icons.flash_on, color: Colors.orange, size: 22),
                ),
                const SizedBox(width: 6),
                Text(
                  'ללא מנוחה – סופר סט!',
                  style: GoogleFonts.assistant(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          if (restTime == 0) const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RestTimeButton(
                icon: Icons.remove_circle_outline,
                color: Colors.redAccent,
                onTap: () {
                  if (restTime > minRest) _updateRestTime(-5);
                },
                onLongPress: () {
                  if (restTime > minRest + 10) {
                    _updateRestTime(-15);
                  }
                },
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorMain.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: restTime != widget.initialRest
                          ? colorAccent
                          : colorMain.withOpacity(0.28),
                      width: restTime != widget.initialRest ? 2.2 : 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        child: TextFormField(
                          controller: controller,
                          autofocus: true,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.assistant(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: colorMain,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (restTime != widget.initialRest)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(Icons.info,
                              color: colorAccent,
                              size: 20,
                              semanticLabel: 'ערך שונה'),
                        ),
                      const SizedBox(width: 2),
                      const Text('שניות',
                          style: TextStyle(fontSize: 15, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              RestTimeButton(
                icon: Icons.add_circle_outline,
                color: Colors.green,
                onTap: () {
                  if (restTime < maxRest) _updateRestTime(5);
                },
                onLongPress: () {
                  if (restTime < maxRest - 10) {
                    _updateRestTime(15);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.refresh,
                    size: 18, semanticLabel: 'איפוס ערך'),
                label: Text(
                  restTime == defaultRest
                      ? 'כבר בברירת מחדל'
                      : 'לאפס לברירת מחדל',
                  style: GoogleFonts.assistant(),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorAccent,
                  textStyle: GoogleFonts.assistant(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onPressed: () =>
                    setState(() => _updateRestTime(defaultRest - restTime)),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          child: Text('ביטול',
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorMain,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('שמור',
              style: GoogleFonts.assistant(
                  fontWeight: FontWeight.bold, fontSize: 15)),
          onPressed: () {
            widget.onSave(restTime);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
