// lib/features/workouts/screens/workout_mode/widgets/set_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../theme/app_theme.dart';

class SetRow extends StatelessWidget {
  final int setIdx;
  final dynamic set;
  final bool isDone;
  final bool isResting;
  final int restSeconds;
  final VoidCallback? onToggleDone;
  final VoidCallback? onEdit;

  const SetRow({
    super.key,
    required this.setIdx,
    required this.set,
    required this.isDone,
    required this.isResting,
    required this.restSeconds,
    this.onToggleDone,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    Color bgColor;
    Color borderColor;
    if (isResting) {
      bgColor = Colors.orange.withAlpha(40);
      borderColor = Colors.orange;
    } else if (isDone) {
      bgColor = Colors.green.withAlpha(38);
      borderColor = Colors.green;
    } else {
      bgColor = colors.background;
      borderColor = colors.primary.withAlpha(35);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ListTile(
        leading: Semantics(
          label: isDone
              ? 'סט מסומן כהושלם'
              : isResting
                  ? 'סט בזמן מנוחה'
                  : 'סט לא הושלם',
          button: true,
          child: InkWell(
            onTap: onToggleDone,
            customBorder: const CircleBorder(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: isDone
                  ? Icon(Icons.check_circle,
                      color: Colors.green, key: const ValueKey('done'))
                  : isResting
                      ? Icon(Icons.timer,
                          color: Colors.orange, key: const ValueKey('resting'))
                      : Icon(Icons.radio_button_unchecked,
                          color: colors.primary,
                          key: const ValueKey('notdone')),
            ),
          ),
        ),
        title: Semantics(
          button: true,
          label: 'עריכת סט ${setIdx + 1}',
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Text(
                  'סט ${setIdx + 1}',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? Colors.green[600]
                        : isResting
                            ? Colors.orange
                            : colors.text,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${set.reps} חזרות',
                  style: GoogleFonts.assistant(
                    color: colors.headline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${set.weight?.toInt() ?? 0} ק"ג',
                  style: GoogleFonts.assistant(
                    color: colors.headline,
                  ),
                ),
              ],
            ),
          ),
        ),
        trailing: isResting
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$restSeconds',
                    style: GoogleFonts.assistant(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.timer_outlined,
                      color: Colors.orange, size: 22),
                ],
              )
            : null,
      ),
    );
  }
}
