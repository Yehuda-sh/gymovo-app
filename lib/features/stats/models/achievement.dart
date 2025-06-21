// lib/features/stats/models/achievement.dart
import 'package:flutter/material.dart';

// 🔧 הוספת enum לסוגי הישגים
enum AchievementType {
  workout,
  duration,
  streak,
  weight,
  consistency,
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final DateTime? unlockedAt;
  final AchievementType type; // 🔧 הוספת סוג הישג
  final int? targetValue; // 🔧 הערך הנדרש להישג
  final String? rarity; // 🔧 נדירות ההישג

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    this.type = AchievementType.workout, // ברירת מחדל
    this.targetValue,
    this.rarity = 'common',
  });

  // 🔧 האם ההישג נפתח
  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      title: map['title'] as String,
      description: map['description'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
      type: AchievementType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AchievementType.workout,
      ),
      targetValue: map['target_value'] as int?,
      rarity: map['rarity'] as String? ?? 'common',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'type': type.name,
      'target_value': targetValue,
      'rarity': rarity,
    };
  }

  Achievement copyWith({
    String? title,
    String? description,
    IconData? icon,
    DateTime? unlockedAt,
    AchievementType? type,
    int? targetValue,
    String? rarity,
  }) {
    return Achievement(
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      rarity: rarity ?? this.rarity,
    );
  }

  // 🔧 פתיחת ההישג
  Achievement unlock() {
    return copyWith(unlockedAt: DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement &&
        other.title == title &&
        other.description == description;
  }

  @override
  int get hashCode => title.hashCode ^ description.hashCode;
}

class AchievementService {
  // 🔧 רשימת כל ההישגים האפשריים
  static List<Achievement> get allAchievements => [
        // הישגי אימונים
        const Achievement(
          title: 'מתחיל',
          description: 'השלמת 10 אימונים',
          icon: Icons.emoji_events,
          type: AchievementType.workout,
          targetValue: 10,
          rarity: 'common',
        ),
        const Achievement(
          title: 'מתקדם',
          description: 'השלמת 50 אימונים',
          icon: Icons.military_tech,
          type: AchievementType.workout,
          targetValue: 50,
          rarity: 'rare',
        ),
        const Achievement(
          title: 'מקצוען',
          description: 'השלמת 100 אימונים',
          icon: Icons.workspace_premium,
          type: AchievementType.workout,
          targetValue: 100,
          rarity: 'epic',
        ),
        const Achievement(
          title: 'אלוף',
          description: 'השלמת 500 אימונים',
          icon: Icons.diamond,
          type: AchievementType.workout,
          targetValue: 500,
          rarity: 'legendary',
        ),

        // הישגי זמן
        const Achievement(
          title: 'מתמיד',
          description: 'השלמת 1000 דקות אימון',
          icon: Icons.timer,
          type: AchievementType.duration,
          targetValue: 1000,
          rarity: 'common',
        ),
        const Achievement(
          title: 'מרתוני',
          description: 'השלמת 5000 דקות אימון',
          icon: Icons.schedule,
          type: AchievementType.duration,
          targetValue: 5000,
          rarity: 'rare',
        ),

        // הישגי עקביות
        const Achievement(
          title: 'שבוע מושלם',
          description: '7 ימי אימון ברצף',
          icon: Icons.local_fire_department,
          type: AchievementType.streak,
          targetValue: 7,
          rarity: 'rare',
        ),
        const Achievement(
          title: 'חודש מושלם',
          description: '30 ימי אימון ברצף',
          icon: Icons.whatshot,
          type: AchievementType.streak,
          targetValue: 30,
          rarity: 'epic',
        ),
      ];

  // 🔧 בדיקת הישגים נוכחיים
  static List<Achievement> getUnlockedAchievements(
    List<Map<String, dynamic>> workouts,
  ) {
    final achievements = <Achievement>[];
    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();

    // בדיקת כל ההישגים האפשריים
    for (final achievement in allAchievements) {
      if (_shouldUnlockAchievement(achievement, completedWorkouts)) {
        achievements.add(achievement.unlock());
      }
    }

    return achievements;
  }

  // 🔧 בדיקה האם הישג צריך להיפתח
  static bool _shouldUnlockAchievement(
    Achievement achievement,
    List<Map<String, dynamic>> completedWorkouts,
  ) {
    switch (achievement.type) {
      case AchievementType.workout:
        return completedWorkouts.length >= (achievement.targetValue ?? 0);

      case AchievementType.duration:
        final totalDuration = completedWorkouts.fold<int>(
          0,
          (sum, workout) => sum + (workout['duration'] as int? ?? 0),
        );
        return totalDuration >= (achievement.targetValue ?? 0);

      case AchievementType.streak:
        return _calculateCurrentStreak(completedWorkouts) >=
            (achievement.targetValue ?? 0);

      default:
        return false;
    }
  }

  // 🔧 חישוב רצף נוכחי
  static int _calculateCurrentStreak(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) return 0;

    // מיון לפי תאריך
    final sortedWorkouts = List<Map<String, dynamic>>.from(workouts);
    sortedWorkouts.sort((a, b) {
      final dateA = DateTime.parse(a['completed_at']);
      final dateB = DateTime.parse(b['completed_at']);
      return dateB.compareTo(dateA); // מהחדש לישן
    });

    int streak = 0;
    DateTime? lastDate;

    for (final workout in sortedWorkouts) {
      final workoutDate = DateTime.parse(workout['completed_at']);
      final dayOnly =
          DateTime(workoutDate.year, workoutDate.month, workoutDate.day);

      if (lastDate == null) {
        // האימון הראשון
        lastDate = dayOnly;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(dayOnly).inDays;

        if (daysDifference == 1) {
          // יום עוקב
          streak++;
          lastDate = dayOnly;
        } else if (daysDifference == 0) {
          // אותו יום - לא נוסיף לרצף
          continue;
        } else {
          // הפסקה ברצף
          break;
        }
      }
    }

    return streak;
  }

  // 🔧 קבלת הישגים חדשים (שעדיין לא נפתחו)
  static List<Achievement> getNewAchievements(
    List<Map<String, dynamic>> workouts,
    List<Achievement> previousAchievements,
  ) {
    final currentAchievements = getUnlockedAchievements(workouts);
    final previousTitles = previousAchievements.map((a) => a.title).toSet();

    return currentAchievements
        .where((achievement) => !previousTitles.contains(achievement.title))
        .toList();
  }

  // 🔧 סטטיסטיקות כלליות
  static Map<String, dynamic> getAchievementStats(
    List<Map<String, dynamic>> workouts,
  ) {
    final unlockedAchievements = getUnlockedAchievements(workouts);
    final totalAchievements = allAchievements.length;

    return {
      'unlocked': unlockedAchievements.length,
      'total': totalAchievements,
      'percentage':
          (unlockedAchievements.length / totalAchievements * 100).round(),
      'current_streak': _calculateCurrentStreak(
        workouts.where((w) => w['completed_at'] != null).toList(),
      ),
    };
  }
}
