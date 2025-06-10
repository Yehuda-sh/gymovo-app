import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';
import '../widgets/rest_time_button.dart';

class EditRestDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    int restTime = initialRest;
    final defaultRest = 60;
    final minRest = 0;
    final maxRest = 600;
    final Color colorMain = AppTheme.colors.primary;
    final Color colorAccent = AppTheme.colors.accent;
    final TextEditingController controller =
        TextEditingController(text: restTime.toString());

    return AlertDialog(
      backgroundColor: AppTheme.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.only(top: 18),
      title: Center(
        child: Column(
          children: [
            Icon(Icons.timer,
                size: 56, color: colorMain, semanticLabel: 'טיימר'),
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
      content: StatefulBuilder(
        builder: (context, setState) {
          // עדכון קלט מהשדה
          controller.text = restTime.toString();
          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length));

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ברירת המחדל: $defaultRest שניות. ניתן לשנות או לאפס.',
                style: GoogleFonts.assistant(
                    fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (restTime == 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on,
                        color: Colors.orange,
                        size: 22,
                        semanticLabel: 'סופר סט'),
                    SizedBox(width: 6),
                    Text('ללא מנוחה – סופר סט!',
                        style: GoogleFonts.assistant(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        )),
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
                      if (restTime > minRest) setState(() => restTime -= 5);
                    },
                    onLongPress: () {
                      if (restTime > minRest + 10)
                        setState(() => restTime -= 15);
                    },
                  ),
                  // Expanded למנוע גלישה:
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: colorMain.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: restTime != initialRest
                              ? colorAccent
                              : colorMain.withOpacity(0.28),
                          width: restTime != initialRest ? 2.2 : 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // שדה קלט מספרי קטן וקריא
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              controller: controller,
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
                              onChanged: (val) {
                                final parsed = int.tryParse(val) ?? restTime;
                                if (parsed >= minRest && parsed <= maxRest) {
                                  setState(() => restTime = parsed);
                                }
                              },
                            ),
                          ),
                          if (restTime != initialRest)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.info,
                                  color: colorAccent,
                                  size: 20,
                                  semanticLabel: 'ערך שונה'),
                            ),
                          const SizedBox(width: 2),
                          const Text('שניות',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  RestTimeButton(
                    icon: Icons.add_circle_outline,
                    color: Colors.green,
                    onTap: () {
                      if (restTime < maxRest) setState(() => restTime += 5);
                    },
                    onLongPress: () {
                      if (restTime < maxRest - 10)
                        setState(() => restTime += 15);
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
                    onPressed: () => setState(() => restTime = defaultRest),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          );
        },
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
            onSave(restTime);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
