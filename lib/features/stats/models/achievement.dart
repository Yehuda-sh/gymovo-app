import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final DateTime? unlockedAt;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      title: map['title'] as String,
      description: map['description'] as String,
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };
  }

  Achievement copyWith({
    String? title,
    String? description,
    IconData? icon,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

class AchievementService {
  static List<Achievement> getAchievements(
      List<Map<String, dynamic>> workouts) {
    final achievements = <Achievement>[];
    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();

    // הישגים לפי מספר אימונים
    if (completedWorkouts.length >= 10) {
      achievements.add(const Achievement(
        title: 'מתחיל',
        description: 'השלמת 10 אימונים',
        icon: Icons.emoji_events,
      ));
    }
    if (completedWorkouts.length >= 50) {
      achievements.add(const Achievement(
        title: 'מתקדם',
        description: 'השלמת 50 אימונים',
        icon: Icons.emoji_events,
      ));
    }
    if (completedWorkouts.length >= 100) {
      achievements.add(const Achievement(
        title: 'מקצוען',
        description: 'השלמת 100 אימונים',
        icon: Icons.emoji_events,
      ));
    }

    // הישגים לפי זמן אימון
    final totalDuration = completedWorkouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['duration'] as int? ?? 0),
    );
    if (totalDuration >= 1000) {
      achievements.add(const Achievement(
        title: 'מתמיד',
        description: 'השלמת 1000 דקות אימון',
        icon: Icons.timer,
      ));
    }

    return achievements;
  }
}
