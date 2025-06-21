// lib/screens/login/login_divider.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginDivider extends StatelessWidget {
  final String text;

  const LoginDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dividerColor = colors.onSurface.withOpacity(0.2);
    final textColor = colors.onSurface.withOpacity(0.7);

    return Row(
      children: [
        Expanded(
          child: Divider(color: dividerColor),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.assistant(color: textColor),
            semanticsLabel: text,
          ),
        ),
        Expanded(
          child: Divider(color: dividerColor),
        ),
      ],
    );
  }
}
