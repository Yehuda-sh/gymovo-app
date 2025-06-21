// lib/widgets/workout/rest_timer.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class RestTimer extends StatelessWidget {
  final int timeRemaining;
  final VoidCallback onSkip;
  final VoidCallback onContinue;
  final VoidCallback onStopRest;

  const RestTimer({
    super.key,
    required this.timeRemaining,
    required this.onSkip,
    required this.onContinue,
    required this.onStopRest,
  });

  String _formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final isWarning = timeRemaining <= 10;
    final isCritical = timeRemaining <= 5;

    return Semantics(
      label: 'טיימר מנוחה',
      value: 'נשארו ${_formatRestTime(timeRemaining)} דקות',
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isWarning
              ? Colors.orange.withOpacity(isCritical ? 0.22 : 0.17)
              : colors.primary.withOpacity(0.13),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(16),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isWarning ? Colors.orange : colors.primary,
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: isWarning ? Colors.orange : colors.primary,
                  size: 28,
                ),
                const SizedBox(width: 9),
                Text(
                  'זמן מנוחה: ',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.headline,
                  ),
                ),
                // אנימציה במעבר שניות
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: (timeRemaining + 1).toDouble(),
                    end: timeRemaining.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) => Text(
                    _formatRestTime(value.toInt()),
                    style: GoogleFonts.assistant(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: isCritical
                          ? Colors.red
                          : (isWarning ? Colors.orange : colors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 19),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  label: 'דלג',
                  icon: Icons.skip_next_rounded,
                  color: colors.secondary,
                  onPressed: onSkip,
                ),
                _ActionButton(
                  label: 'המשך',
                  icon: Icons.play_arrow_rounded,
                  color: colors.primary,
                  onPressed: onContinue,
                ),
                _ActionButton(
                  label: 'הפסק מנוחה',
                  icon: Icons.stop_circle_rounded,
                  color: colors.error,
                  onPressed: onStopRest,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: TextButton.icon(
        icon: Icon(icon, size: 22, color: color),
        label: Text(
          label,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          foregroundColor: color,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
