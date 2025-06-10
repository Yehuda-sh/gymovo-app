import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class MotivationCard extends StatelessWidget {
  final dynamic user;
  const MotivationCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface.withOpacity(0.91),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: colors.headline, size: 34),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              '${user?.name?.isNotEmpty == true ? user!.name : "מתאמן"} – זה הזמן לקחת צעד קדימה ולהתחיל את השבוע באנרגיה חיובית!',
              style: GoogleFonts.assistant(
                color: colors.headline,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
