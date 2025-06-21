// lib/features/stats/services/stats_export_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/achievement.dart';

enum ExportFormat { json, csv, txt }

enum AchievementRarity { common, rare, epic, legendary }

// מחלקה זמנית להישגים (להחליף עם המחלקה הקיימת שלך)
class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final DateTime? unlockedAt;
  final AchievementRarity rarity;
  final String? tip;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    required this.rarity,
    this.tip,
  });
}

// שירות להישגים (להחליף עם השירות הקיים שלך)
class AchievementService {
  static List<Achievement> getAchievements(
      List<Map<String, dynamic>> workouts) {
    List<Achievement> achievements = [];

    // הישג ראשון
    if (workouts.isNotEmpty) {
      achievements.add(Achievement(
        title: "אימון ראשון",
        description: "יצאת לדרך - ביצעת את האימון הראשון שלך!",
        icon: Icons.emoji_events,
        unlockedAt: DateTime.parse(workouts.first['completed_at']),
        rarity: AchievementRarity.common,
      ));
    }

    // הישג 5 אימונים
    if (workouts.length >= 5) {
      achievements.add(Achievement(
        title: "5 אימונים",
        description: "השלמת 5 אימונים - נתחיל ברצינות!",
        icon: Icons.fitness_center,
        rarity: AchievementRarity.common,
        tip: "המשך כך ותגיע ליעדים!",
      ));
    }

    // הישג 10 אימונים
    if (workouts.length >= 10) {
      achievements.add(Achievement(
        title: "10 אימונים",
        description: "עכשיו זה נהיה הרגל!",
        icon: Icons.star,
        rarity: AchievementRarity.rare,
      ));
    }

    // הישג שבועי
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final thisWeekWorkouts = workouts
        .where((w) => DateTime.parse(w['completed_at']).isAfter(lastWeek))
        .length;

    if (thisWeekWorkouts >= 3) {
      achievements.add(Achievement(
        title: "ספורטאי השבוע",
        description: "השלמת 3 אימונים או יותר השבוע!",
        icon: Icons.sports,
        rarity: AchievementRarity.rare,
        tip: "עקוב אחר התקדמותך בלוח השנה!",
      ));
    }

    // הישג זמן ארוך
    final totalDuration =
        workouts.fold<int>(0, (sum, w) => sum + (w['duration'] as int? ?? 0));
    if (totalDuration >= 1000) {
      // 1000 דקות
      achievements.add(Achievement(
        title: "1000 דקות",
        description: "צברת 1000 דקות של אימונים!",
        icon: Icons.timer,
        rarity: AchievementRarity.epic,
      ));
    }

    return achievements;
  }
}

class StatsExportService {
  /// ייצוא סטטיסטיקות במספר פורמטים
  static Future<bool> exportStats({
    required List<Map<String, dynamic>> workouts,
    ExportFormat format = ExportFormat.json,
    Function(String)? onError,
  }) async {
    try {
      final completedWorkouts =
          workouts.where((w) => w['completed_at'] != null).toList();

      if (completedWorkouts.isEmpty) {
        onError?.call('אין נתוני אימונים לייצוא');
        return false;
      }

      switch (format) {
        case ExportFormat.json:
          return await _exportAsJson(completedWorkouts, onError);
        case ExportFormat.csv:
          return await _exportAsCsv(completedWorkouts, onError);
        case ExportFormat.txt:
          return await _exportAsText(completedWorkouts, onError);
      }
    } catch (e) {
      onError?.call('שגיאה בייצוא הנתונים: $e');
      return false;
    }
  }

  /// ייצוא כ-JSON מפורט
  static Future<bool> _exportAsJson(
    List<Map<String, dynamic>> workouts,
    Function(String)? onError,
  ) async {
    final stats = _generateStatsData(workouts);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = _formatTimestamp();
      final file = File('${directory.path}/gymovo_stats_$timestamp.json');

      // JSON יפה וקריא
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(stats), encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Gymovo - סטטיסטיקות אימונים מפורטות',
        subject: 'סטטיסטיקות אימונים ${_formatDate(DateTime.now())}',
      );

      return true;
    } catch (e) {
      onError?.call('שגיאה בייצוא JSON: $e');
      return false;
    }
  }

  /// ייצוא כ-CSV לאקסל
  static Future<bool> _exportAsCsv(
    List<Map<String, dynamic>> workouts,
    Function(String)? onError,
  ) async {
    try {
      final csvContent = _generateCsvContent(workouts);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = _formatTimestamp();
      final file = File('${directory.path}/gymovo_workouts_$timestamp.csv');

      await file.writeAsString(csvContent, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Gymovo - היסטוריית אימונים (CSV)',
        subject: 'נתוני אימונים לאקסל',
      );

      return true;
    } catch (e) {
      onError?.call('שגיאה בייצוא CSV: $e');
      return false;
    }
  }

  /// ייצוא כטקסט קריא
  static Future<bool> _exportAsText(
    List<Map<String, dynamic>> workouts,
    Function(String)? onError,
  ) async {
    try {
      final textContent = _generateTextReport(workouts);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = _formatTimestamp();
      final file = File('${directory.path}/gymovo_report_$timestamp.txt');

      await file.writeAsString(textContent, encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Gymovo - דוח אימונים',
        subject: 'דוח אימונים אישי',
      );

      return true;
    } catch (e) {
      onError?.call('שגיאה בייצוא דוח: $e');
      return false;
    }
  }

  /// יצירת נתוני הסטטיסטיקות המלאים
  static Map<String, dynamic> _generateStatsData(
      List<Map<String, dynamic>> workouts) {
    final generalStats = _calculateGeneralStats(workouts);
    final exerciseStats = _getExerciseStats(workouts);
    final achievements = AchievementService.getAchievements(workouts);

    return {
      'export_info': {
        'date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0', // אפשר לעדכן דינמית
        'format_version': '1.2',
        'total_workouts': workouts.length,
      },
      'summary': {
        'period':
            '${_formatDate(_getFirstWorkoutDate(workouts))} - ${_formatDate(DateTime.now())}',
        ...generalStats,
      },
      'achievements': achievements
          .map((a) => {
                'title': a.title,
                'description': a.description,
                'rarity': a.rarity.toString(),
                'unlocked_at': a.unlockedAt?.toIso8601String(),
                'tip': a.tip,
              })
          .toList(),
      'exercise_analysis': exerciseStats,
      'monthly_breakdown': _getMonthlyBreakdown(workouts),
      'workout_history': workouts
          .map((w) => {
                'date': w['completed_at'],
                'title': w['title'],
                'duration_minutes': w['duration'],
                'exercises_count': (w['exercises'] as List).length,
                'rating': w['rating'],
                'feedback': w['feedback'],
                'exercises': _formatExercisesForExport(w['exercises'] as List),
              })
          .toList(),
    };
  }

  /// חישוב סטטיסטיקות כלליות משופרות
  static Map<String, dynamic> _calculateGeneralStats(
      List<Map<String, dynamic>> workouts) {
    final totalDuration = workouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['duration'] as int? ?? 0),
    );

    final totalExercises = workouts.fold<int>(
      0,
      (sum, workout) => sum + (workout['exercises'] as List).length,
    );

    final avgDuration = workouts.isEmpty ? 0 : totalDuration / workouts.length;
    final avgExercises =
        workouts.isEmpty ? 0 : totalExercises / workouts.length;

    // חישוב תדירות אימונים
    final firstWorkout = _getFirstWorkoutDate(workouts);
    final daysSinceStart = DateTime.now().difference(firstWorkout).inDays + 1;
    final workoutsPerWeek = workouts.length / (daysSinceStart / 7);

    return {
      'total_workouts': workouts.length,
      'total_duration_minutes': totalDuration,
      'total_duration_formatted': _formatDuration(totalDuration),
      'total_exercises': totalExercises,
      'average_duration_minutes': avgDuration.round(),
      'average_exercises_per_workout': avgExercises.round(),
      'workouts_per_week': workoutsPerWeek.toStringAsFixed(1),
      'days_active': daysSinceStart,
      'longest_workout': _getLongestWorkout(workouts),
      'most_exercises_in_workout': _getMostExercisesInWorkout(workouts),
    };
  }

  /// סטטיסטיקות תרגילים משופרות
  static List<Map<String, dynamic>> _getExerciseStats(
      List<Map<String, dynamic>> workouts) {
    final exerciseStats = <String, Map<String, int>>{};

    for (final workout in workouts) {
      for (final exercise in workout['exercises'] as List) {
        final name = exercise['name'] as String;
        final sets = (exercise['sets'] as List).length;

        exerciseStats[name] ??= {'workouts': 0, 'total_sets': 0};
        exerciseStats[name]!['workouts'] =
            exerciseStats[name]!['workouts']! + 1;
        exerciseStats[name]!['total_sets'] =
            exerciseStats[name]!['total_sets']! + sets;
      }
    }

    final sorted = exerciseStats.entries.toList()
      ..sort(
          (a, b) => b.value['total_sets']!.compareTo(a.value['total_sets']!));

    return sorted
        .map((e) => {
              'name': e.key,
              'total_sets': e.value['total_sets'],
              'workouts_count': e.value['workouts'],
              'avg_sets_per_workout':
                  (e.value['total_sets']! / e.value['workouts']!)
                      .toStringAsFixed(1),
            })
        .toList();
  }

  /// פילוח חודשי
  static List<Map<String, dynamic>> _getMonthlyBreakdown(
      List<Map<String, dynamic>> workouts) {
    final monthlyData = <String, Map<String, int>>{};

    for (final workout in workouts) {
      final date = DateTime.parse(workout['completed_at']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      monthlyData[monthKey] ??= {
        'workouts': 0,
        'duration': 0,
        'exercises': 0,
      };

      monthlyData[monthKey]!['workouts'] =
          monthlyData[monthKey]!['workouts']! + 1;
      monthlyData[monthKey]!['duration'] = monthlyData[monthKey]!['duration']! +
          (workout['duration'] as int? ?? 0);
      monthlyData[monthKey]!['exercises'] =
          monthlyData[monthKey]!['exercises']! +
              (workout['exercises'] as List).length;
    }

    return monthlyData.entries
        .map((e) => {
              'month': e.key,
              'workouts': e.value['workouts'],
              'total_duration': e.value['duration'],
              'total_exercises': e.value['exercises'],
            })
        .toList()
      ..sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
  }

  /// יצירת תוכן CSV
  static String _generateCsvContent(List<Map<String, dynamic>> workouts) {
    final buffer = StringBuffer();

    // כותרות
    buffer.writeln('תאריך,שם האימון,משך (דקות),מספר תרגילים,דירוג,משוב');

    // נתונים
    for (final workout in workouts) {
      final date = _formatDate(DateTime.parse(workout['completed_at']));
      final title = _escapeCsvField(workout['title']?.toString() ?? '');
      final duration = workout['duration']?.toString() ?? '0';
      final exercisesCount = (workout['exercises'] as List).length.toString();
      final rating = workout['rating']?.toString() ?? '';
      final feedback = _escapeCsvField(workout['feedback']?.toString() ?? '');

      buffer
          .writeln('$date,$title,$duration,$exercisesCount,$rating,$feedback');
    }

    return buffer.toString();
  }

  /// יצירת דוח טקסט
  static String _generateTextReport(List<Map<String, dynamic>> workouts) {
    final buffer = StringBuffer();
    final stats = _calculateGeneralStats(workouts);

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('           דוח אימונים אישי');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('נוצר ב: ${_formatDate(DateTime.now())}');
    buffer.writeln('');

    buffer.writeln('📊 סיכום כללי:');
    buffer.writeln('├─ סך הכל אימונים: ${stats['total_workouts']}');
    buffer.writeln('├─ זמן כולל: ${stats['total_duration_formatted']}');
    buffer
        .writeln('├─ ממוצע לאימון: ${stats['average_duration_minutes']} דקות');
    buffer.writeln('├─ אימונים בשבוע: ${stats['workouts_per_week']}');
    buffer.writeln('└─ ימי פעילות: ${stats['days_active']}');
    buffer.writeln('');

    // תרגילים מובילים
    final topExercises = _getExerciseStats(workouts).take(5);
    buffer.writeln('🏋️ תרגילים מובילים:');
    for (int i = 0; i < topExercises.length; i++) {
      final exercise = topExercises.elementAt(i);
      buffer.writeln(
          '${i + 1}. ${exercise['name']} - ${exercise['total_sets']} סטים');
    }
    buffer.writeln('');

    // היסטוריה אחרונה
    buffer.writeln('📅 אימונים אחרונים:');
    final recentWorkouts = workouts.reversed.take(5);
    for (final workout in recentWorkouts) {
      final date = _formatDate(DateTime.parse(workout['completed_at']));
      final title = workout['title']?.toString() ?? 'אימון';
      final duration = workout['duration']?.toString() ?? '0';
      buffer.writeln('• $date - $title ($duration דקות)');
    }

    buffer.writeln('');
    buffer.writeln('💪 המשך כך! ההתקדמות שלך מרשימה!');

    return buffer.toString();
  }

  // פונקציות עזר
  static String _formatTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}ד';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}ש ${remainingMinutes}ד';
  }

  static DateTime _getFirstWorkoutDate(List<Map<String, dynamic>> workouts) {
    if (workouts.isEmpty) return DateTime.now();
    return workouts
        .map((w) => DateTime.parse(w['completed_at']))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  static int _getLongestWorkout(List<Map<String, dynamic>> workouts) {
    return workouts.fold<int>(0, (max, w) {
      final duration = w['duration'] as int? ?? 0;
      return duration > max ? duration : max;
    });
  }

  static int _getMostExercisesInWorkout(List<Map<String, dynamic>> workouts) {
    return workouts.fold<int>(0, (max, w) {
      final exercisesCount = (w['exercises'] as List).length;
      return exercisesCount > max ? exercisesCount : max;
    });
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static List<Map<String, dynamic>> _formatExercisesForExport(List exercises) {
    return exercises
        .map<Map<String, dynamic>>((exercise) => {
              'name': exercise['name'],
              'sets_count': (exercise['sets'] as List).length,
              'sets_details': (exercise['sets'] as List)
                  .map((set) => {
                        'reps': set['reps'],
                        'weight': set['weight'],
                        'duration': set['duration'],
                      })
                  .toList(),
            })
        .toList();
  }
}
