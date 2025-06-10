import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../models/achievement.dart';

class StatsExportService {
  static Future<void> exportStats(List<Map<String, dynamic>> workouts) async {
    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();

    // יצירת נתונים לייצוא
    final stats = {
      'תאריך יצוא': DateTime.now().toIso8601String(),
      'סטטיסטיקות כללית': {
        'מספר אימונים': completedWorkouts.length,
        'זמן אימון כולל': completedWorkouts.fold<int>(
          0,
          (sum, workout) => sum + (workout['duration'] as int? ?? 0),
        ),
        'מספר תרגילים': completedWorkouts.fold<int>(
          0,
          (sum, workout) => sum + (workout['exercises'] as List).length,
        ),
      },
      'הישגים': AchievementService.getAchievements(completedWorkouts)
          .map((a) => a.toMap())
          .toList(),
      'סטטיסטיקות תרגילים': _getExerciseStats(completedWorkouts),
      'היסטוריית אימונים': completedWorkouts
          .map((w) => {
                'תאריך': w['completed_at'],
                'שם': w['title'],
                'משך': w['duration'],
                'תרגילים': (w['exercises'] as List).length,
                'דירוג': w['rating'],
                'משוב': w['feedback'],
              })
          .toList(),
    };

    // שמירת הקובץ
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/workout_stats_$timestamp.json');
    await file.writeAsString(jsonEncode(stats), encoding: utf8);

    // שיתוף הקובץ
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'סטטיסטיקות אימונים שלי מ־Gymovo',
    );
  }

  static Map<String, dynamic> _getExerciseStats(
      List<Map<String, dynamic>> workouts) {
    final exerciseStats = <String, int>{};

    // חישוב סטטיסטיקות תרגילים
    for (final workout in workouts) {
      for (final exercise in workout['exercises'] as List) {
        exerciseStats[exercise['name'] as String] =
            (exerciseStats[exercise['name'] as String] ?? 0) +
                (exercise['sets'] as List).length;
      }
    }

    // מיון תרגילים לפי כמות סטים
    final sortedExercises = exerciseStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return exerciseStats;
  }
}
