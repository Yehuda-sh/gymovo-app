import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginHeader extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const LoginHeader({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          children: [
            Image.asset(
              'assets/images/gymovo_logo.png',
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'ברוכים הבאים ל-Gymovo',
              style: GoogleFonts.assistant(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'התחברו כדי להתחיל להתאמן',
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
