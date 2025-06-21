// lib/features/workouts/screens/workout_details/widgets/workout_info_chip.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? tooltip;

  const WorkoutInfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final chipContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      constraints: const BoxConstraints(minWidth: 50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.assistant(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip!,
        child: Semantics(
          label: tooltip,
          child: chipContent,
        ),
      );
    } else {
      return Semantics(
        label: label,
        child: chipContent,
      );
    }
  }
}
