import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Card(
        elevation: 3,
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
                  : Icon(icon, size: 46, color: colors),
              const SizedBox(width: 16),
              // מידע על ההישג
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.assistant(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors,
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
                        color: Colors.grey[800],
                      ),
                    ),
                    if (tip != null && tip!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.tips_and_updates, size: 16, color: colors),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              tip!,
                              style: GoogleFonts.assistant(
                                fontSize: 13,
                                color: colors.withOpacity(0.75),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (unlockedAt != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green[400], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "הושג: ${_formatDate(unlockedAt!)}",
                            style: GoogleFonts.assistant(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
