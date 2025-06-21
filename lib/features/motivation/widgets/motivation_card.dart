// lib/features/motivation/widgets/motivation_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../models/user_model.dart'; // ודא שקיים

class MotivationCard extends StatelessWidget {
  final UserModel? user;
  const MotivationCard({super.key, this.user});

  // 🔧 שיפור: פונקציה נפרדת לקבלת השם
  String get _displayName {
    if (user?.name?.isNotEmpty == true) {
      return user!.name;
    }
    return "מתאמן";
  }

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
          Icon(
            Icons.emoji_events,
            color: colors.headline,
            size: 34,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              '$_displayName – זה הזמן לקחת צעד קדימה ולהתחיל את השבוע באנרגיה חיובית!', // 🔧 שימוש בפונקציה המשופרת
              style: GoogleFonts.assistant(
                color: colors.headline,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.4, // 🔧 הוספת height לקריאות טובה יותר
              ),
            ),
          ),
        ],
      ),
    );
  }
}
