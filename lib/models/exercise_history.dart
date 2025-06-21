// lib/models/exercise_history.dart
// מודל ישן — לשמירה/טעינה של היסטוריית תרגילים בפורמט הישן

class ExerciseHistory {
  final String exerciseId;
  final List<Map<String, dynamic>> sets;
  final String? lastWorkoutDate;
  final int? totalVolume;
  final int? totalSets;

  ExerciseHistory({
    required this.exerciseId,
    required this.sets,
    this.lastWorkoutDate,
    this.totalVolume,
    this.totalSets,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'sets': sets.map((e) => Map<String, dynamic>.from(e)).toList(),
      'last_workout_date': lastWorkoutDate,
      'total_volume': totalVolume,
      'total_sets': totalSets,
    };
  }

  factory ExerciseHistory.fromMap(Map<String, dynamic> map) {
    return ExerciseHistory(
      exerciseId: map['exercise_id'] ?? '',
      sets: (map['sets'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      lastWorkoutDate: map['last_workout_date'],
      totalVolume: map['total_volume'] as int?,
      totalSets: map['total_sets'] as int?,
    );
  }
}
