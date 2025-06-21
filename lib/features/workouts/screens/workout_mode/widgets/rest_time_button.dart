// lib/features/workouts/screens/workout_mode/widgets/rest_time_button.dart
import 'package:flutter/material.dart';

class RestTimeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const RestTimeButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'כפתור מנוחה',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          customBorder: const CircleBorder(),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
      ),
    );
  }
}
