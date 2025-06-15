import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/achievement.dart';

class StatsExportService {
  static Future<void> exportStats(List<Map<String, dynamic>> workouts) async {
    final completedWorkouts =
        workouts.where((w) => w['completed_at'] != null).toList();

    // יצירת נתונים לייצוא
    final stats = {
      'export_date': DateTime.now().toIso8601String(),
      'general_stats': {
        'workouts_count': completedWorkouts.length,
        'total_duration': completedWorkouts.fold<int>(
          0,
          (sum, workout) => sum + (workout['duration'] as int? ?? 0),
        ),
        'exercises_count': completedWorkouts.fold<int>(
          0,
          (sum, workout) => sum + (workout['exercises'] as List).length,
        ),
      },
      'achievements': AchievementService.getAchievements(completedWorkouts)
          .map((a) => a.toMap())
          .toList(),
      'exercise_stats': _getExerciseStats(completedWorkouts),
      'workout_history': completedWorkouts
          .map((w) => {
                'date': w['completed_at'],
                'title': w['title'],
                'duration': w['duration'],
                'exercises': (w['exercises'] as List).length,
                'rating': w['rating'],
                'feedback': w['feedback'],
              })
          .toList(),
    };

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/workout_stats_$timestamp.json');
      await file.writeAsString(jsonEncode(stats), encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Gymovo - סטטיסטיקות אימונים שלי',
      );
    } catch (e) {
      // אפשר להוסיף כאן callback להודעת שגיאה ב־UI
      print('שגיאה בייצוא הנתונים: $e');
    }
  }

  static List<Map<String, dynamic>> _getExerciseStats(
      List<Map<String, dynamic>> workouts) {
    final exerciseStats = <String, int>{};

    for (final workout in workouts) {
      for (final exercise in workout['exercises'] as List) {
        final name = exercise['name'] as String;
        exerciseStats[name] =
            (exerciseStats[name] ?? 0) + (exercise['sets'] as List).length;
      }
    }

    final sorted = exerciseStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // החזר כמבנה נוח לתצוגה/ייצוא
    return sorted
        .map((e) => {
              'name': e.key,
              'sets': e.value,
            })
        .toList();
  }
}
