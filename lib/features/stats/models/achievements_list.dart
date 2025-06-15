import 'package:flutter/material.dart';
import 'achievement_card.dart';

// דוגמה לרשימת הישגים (אפשר גם להכניס מה-Provider/DB שלך)
final demoAchievements = [
  AchievementCard(
    title: "ספורטאי השבוע",
    description: "השלמת אימון כל יום במשך 7 ימים ברצף.",
    icon: Icons.fitness_center,
    unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
    rarity: AchievementRarity.rare,
    tip: "עקוב אחר התקדמותך בלוח השנה!",
  ),
  AchievementCard(
    title: "1000 חזרות",
    description: "השלמת 1000 חזרות מצטברות.",
    icon: Icons.repeat_on,
    unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
    rarity: AchievementRarity.epic,
    tip: "אל תוותר גם בסטים האחרונים!",
  ),
  AchievementCard(
    title: "אימון ראשון",
    description: "יצאת לדרך - ביצעת את האימון הראשון שלך!",
    icon: Icons.emoji_events,
    unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
    rarity: AchievementRarity.common,
  ),
];

class AchievementsList extends StatelessWidget {
  final List<AchievementCard> achievements;
  const AchievementsList({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: achievements.length,
      itemBuilder: (context, index) => achievements[index],
    );
  }
}

// דוגמה לשימוש בתוך Scaffold:
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ההישגים שלי')),
      body: AchievementsList(achievements: demoAchievements),
    );
  }
}
