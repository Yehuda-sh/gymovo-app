// lib/features/stats/widgets/achievement_card.dart (🔧 מיקום מתוקן)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart'; // 🔧 הוספת import לתמה

enum AchievementRarity { common, rare, epic, legendary }

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final DateTime? unlockedAt;
  final AchievementRarity rarity;
  final String? tip;
  final String? imageUrl;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    this.rarity = AchievementRarity.common,
    this.tip,
    this.imageUrl,
  });

  Color getRarityColor() {
    switch (rarity) {
      case AchievementRarity.rare:
        return Colors.blueAccent;
      case AchievementRarity.epic:
        return Colors.purpleAccent;
      case AchievementRarity.legendary:
        return Colors.amber;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = getRarityColor();
    final theme = AppTheme.colors; // 🔧 שימוש בתמה

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Card(
        elevation: 3,
        color: theme.surface, // 🔧 שימוש בצבע מהתמה
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.withOpacity(0.4), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // אייקון או תמונה
              imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            Icon(icon, size: 46, color: colors),
                      ),
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.withOpacity(0.1), // 🔧 רקע לאייקון
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.withOpacity(0.3)),
                      ),
                      child: Icon(icon, size: 28, color: colors),
                    ),
              const SizedBox(width: 16),
              // מידע על ההישג
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          // 🔧 שיפור לטקסט ארוך
                          child: Text(
                            title,
                            style: GoogleFonts.assistant(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colors,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rarity != AchievementRarity.common) ...[
                          const SizedBox(width: 6),
                          _rarityBadge(rarity),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.assistant(
                        fontSize: 15,
                        color: theme.text.withOpacity(0.8), // 🔧 צבע מהתמה
                        height: 1.3, // 🔧 רווח שורות
                      ),
                    ),
                    if (tip != null && tip!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.tips_and_updates,
                                size: 16, color: colors),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                tip!,
                                style: GoogleFonts.assistant(
                                  fontSize: 13,
                                  color: colors.withOpacity(0.8),
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (unlockedAt != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[600], size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "הושג: ${_formatDate(unlockedAt!)}",
                              style: GoogleFonts.assistant(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // תגית rarity
  Widget _rarityBadge(AchievementRarity rarity) {
    final text = {
      AchievementRarity.rare: "נדיר",
      AchievementRarity.epic: "אפִּי",
      AchievementRarity.legendary: "אגדי",
    }[rarity]!;
    final color = getRarityColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.assistant(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}"; // 🔧 פורמט טוב יותר
  }
}
