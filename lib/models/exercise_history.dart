// lib/models/exercise_history.dart
import 'package:uuid/uuid.dart';
import 'dart:convert';

enum SetType {
  normal,
  warmup,
  failure,
  dropSet,
}

class ExerciseSet {
  final String id;
  final String exerciseId;
  final double weight;
  final int reps;
  final String? notes;
  final bool isCompleted;
  final DateTime date;
  final DateTime createdAt;
  final int? restTime;

  ExerciseSet({
    required this.id,
    required this.exerciseId,
    required this.weight,
    required this.reps,
    this.notes,
    this.isCompleted = true,
    required this.date,
    DateTime? createdAt,
    this.restTime,
  }) : createdAt = createdAt ?? date;

  ExerciseSet copyWith({
    String? id,
    String? exerciseId,
    double? weight,
    int? reps,
    String? notes,
    bool? isCompleted,
    DateTime? date,
    DateTime? createdAt,
    int? restTime,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      restTime: restTime ?? this.restTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'weight': weight,
      'reps': reps,
      'notes': notes,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'restTime': restTime,
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? true,
      date: DateTime.parse(json['date'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      restTime: json['restTime'] as int?,
    );
  }
}

class PersonalRecord {
  final double value;
  final DateTime date;
  final String setId;
  final PRType type;

  PersonalRecord({
    required this.value,
    required this.date,
    required this.setId,
    required this.type,
  });

  factory PersonalRecord.fromMap(Map<String, dynamic> map) {
    return PersonalRecord(
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      setId: map['set_id'] as String,
      type: PRType.values.firstWhere(
        (e) => e.toString() == 'PRType.${map['type']}',
        orElse: () => PRType.weight,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'date': date.toIso8601String(),
      'set_id': setId,
      'type': type.toString().split('.').last,
    };
  }
}

enum PRType {
  weight, // Max weight
  reps, // Max reps
  volume, // Max volume (weight × reps)
  intensity, // Max RPE/RIR
}

class ExerciseHistory {
  final String exerciseId;
  final List<ExerciseSet> sets;
  final DateTime? lastWorkoutDate;
  final List<PersonalRecord> personalRecords;
  final int? totalVolume;
  final int? totalSets;

  ExerciseHistory({
    required this.exerciseId,
    required this.sets,
    this.lastWorkoutDate,
    List<PersonalRecord>? personalRecords,
    this.totalVolume,
    this.totalSets,
  }) : personalRecords = personalRecords ?? [];

  factory ExerciseHistory.fromMap(Map<String, dynamic> map) {
    final exerciseId = map['exercise_id']?.toString() ?? '';
    final setsRaw = map['sets'] as List?;
    List<ExerciseSet> setsList = [];
    if (setsRaw != null) {
      setsList = setsRaw
          .map((e) {
            if (e is ExerciseSet) return e;
            if (e is Map<String, dynamic>) return ExerciseSet.fromJson(e);
            if (e is String) {
              try {
                return ExerciseSet.fromJson(json.decode(e));
              } catch (_) {
                return null;
              }
            }
            return null;
          })
          .whereType<ExerciseSet>()
          .toList();
    }
    final lastWorkoutDate = map['last_workout_date'] != null
        ? DateTime.parse(map['last_workout_date'].toString())
        : null;
    final personalRecordsRaw = map['personal_records'] as List?;
    List<PersonalRecord> personalRecordsList = [];
    if (personalRecordsRaw != null) {
      personalRecordsList = personalRecordsRaw
          .map((e) {
            if (e is PersonalRecord) return e;
            if (e is Map<String, dynamic>) return PersonalRecord.fromMap(e);
            if (e is String) {
              try {
                return PersonalRecord.fromMap(json.decode(e));
              } catch (_) {
                return null;
              }
            }
            return null;
          })
          .whereType<PersonalRecord>()
          .toList();
    }
    final totalVolume = map['total_volume'] as int?;
    final totalSets = map['total_sets'] as int?;
    return ExerciseHistory(
      exerciseId: exerciseId,
      sets: setsList,
      lastWorkoutDate: lastWorkoutDate,
      personalRecords: personalRecordsList,
      totalVolume: totalVolume,
      totalSets: totalSets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'sets': sets.map((e) => e.toJson()).toList(),
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'personal_records': personalRecords.map((e) => e.toMap()).toList(),
      'total_volume': totalVolume,
      'total_sets': totalSets,
    };
  }

  ExerciseHistory copyWith({
    String? exerciseId,
    List<ExerciseSet>? sets,
    DateTime? lastWorkoutDate,
    List<PersonalRecord>? personalRecords,
    int? totalVolume,
    int? totalSets,
  }) {
    return ExerciseHistory(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      personalRecords: personalRecords ?? this.personalRecords,
      totalVolume: totalVolume ?? this.totalVolume,
      totalSets: totalSets ?? this.totalSets,
    );
  }

  List<ExerciseSet> getRecentSets(int count) {
    final sortedSets = List<ExerciseSet>.from(sets)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedSets.take(count).toList();
  }

  Map<String, dynamic> getStatistics() {
    final completedSets = sets.where((set) => set.isCompleted).toList();
    if (completedSets.isEmpty) return {};

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentSets =
        completedSets.where((set) => set.date.isAfter(thirtyDaysAgo));

    return {
      'best_day': _getBestDay(completedSets),
      'streak': _calculateStreak(completedSets),
      'recent_volume': _calculateVolume(recentSets),
      'recent_sets': recentSets.length,
      'recent_avg_weight': _calculateAverageWeight(recentSets),
      'recent_avg_reps': _calculateAverageReps(recentSets),
    };
  }

  DateTime? _getBestDay(List<ExerciseSet> sets) {
    if (sets.isEmpty) return null;

    final volumeByDay = <DateTime, double>{};
    for (final set in sets) {
      final day = DateTime(set.date.year, set.date.month, set.date.day);
      volumeByDay[day] = (volumeByDay[day] ?? 0) + (set.weight * set.reps);
    }

    return volumeByDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _calculateStreak(List<ExerciseSet> sets) {
    if (sets.isEmpty) return 0;

    final dates = sets
        .map((set) => DateTime(set.date.year, set.date.month, set.date.day))
        .toSet()
        .toList()
      ..sort();

    int streak = 1;
    int maxStreak = 1;

    for (int i = 1; i < dates.length; i++) {
      final difference = dates[i].difference(dates[i - 1]).inDays;
      if (difference == 1) {
        streak++;
        maxStreak = streak > maxStreak ? streak : maxStreak;
      } else {
        streak = 1;
      }
    }

    return maxStreak;
  }

  double _calculateVolume(Iterable<ExerciseSet> sets) {
    return sets.fold<double>(0, (sum, set) => sum + (set.weight * set.reps));
  }

  double _calculateAverageWeight(Iterable<ExerciseSet> sets) {
    if (sets.isEmpty) return 0;
    return sets.fold<double>(0, (sum, set) => sum + set.weight) / sets.length;
  }

  double _calculateAverageReps(Iterable<ExerciseSet> sets) {
    if (sets.isEmpty) return 0;
    return sets.fold<int>(0, (sum, set) => sum + set.reps) / sets.length;
  }

  PersonalRecord? getPersonalRecord(PRType type) {
    return personalRecords
        .where((pr) => pr.type == type)
        .reduce((a, b) => a.value > b.value ? a : b);
  }

  void updatePersonalRecords(ExerciseSet set) {
    final records = List<PersonalRecord>.from(personalRecords);
    bool updated = false;

    // Check weight PR
    final weightPR = getPersonalRecord(PRType.weight);
    if (weightPR == null || set.weight > weightPR.value) {
      records.add(PersonalRecord(
        value: set.weight,
        date: set.date,
        setId: set.id,
        type: PRType.weight,
      ));
      updated = true;
    }

    // Check reps PR
    final repsPR = getPersonalRecord(PRType.reps);
    if (repsPR == null || set.reps > repsPR.value) {
      records.add(PersonalRecord(
        value: set.reps.toDouble(),
        date: set.date,
        setId: set.id,
        type: PRType.reps,
      ));
      updated = true;
    }

    // Check volume PR
    final volume = set.weight * set.reps;
    final volumePR = getPersonalRecord(PRType.volume);
    if (volumePR == null || volume > volumePR.value) {
      records.add(PersonalRecord(
        value: volume,
        date: set.date,
        setId: set.id,
        type: PRType.volume,
      ));
      updated = true;
    }

    if (updated) {
      personalRecords.clear();
      personalRecords.addAll(records);
    }
  }
}
