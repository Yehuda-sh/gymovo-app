// features/auth/widgets/social_login_button.dart;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed; // כאן שינוי קטן!
  final bool isLoading;
  final Color color;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed, // עכשיו אפשר גם null
    this.isLoading = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed, // עובד מושלם עם VoidCallback?
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
              ),
            )
          : Icon(icon, color: colors.onPrimary),
      label: Text(
        label,
        style: GoogleFonts.assistant(
          color: colors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: colors.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}
