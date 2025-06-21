// lib/models/unified_models.dart
// מודלים מאוחדים לאפליקציית הכושר

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ==============================================================================
// ENUMS
// ==============================================================================

enum SetType {
  normal,
  warmup,
  failure,
  dropSet;

  String get displayName {
    switch (this) {
      case SetType.normal:
        return 'רגיל';
      case SetType.warmup:
        return 'חימום';
      case SetType.failure:
        return 'כישלון';
      case SetType.dropSet:
        return 'דרופ סט';
    }
  }
}

enum PRType {
  weight, // משקל מקסימלי
  reps, // חזרות מקסימליות
  volume, // נפח מקסימלי (משקל × חזרות)
  intensity; // עוצמה מקסימלית

  String get displayName {
    switch (this) {
      case PRType.weight:
        return 'משקל מקסימלי';
      case PRType.reps:
        return 'חזרות מקסימליות';
      case PRType.volume:
        return 'נפח מקסימלי';
      case PRType.intensity:
        return 'עוצמה מקסימלית';
    }
  }
}

enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return 'גבר';
      case Gender.female:
        return 'אישה';
      case Gender.other:
        return 'אחר';
    }
  }
}

enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
  expert;

  String get displayName {
    switch (this) {
      case ExperienceLevel.beginner:
        return 'מתחיל';
      case ExperienceLevel.intermediate:
        return 'בינוני';
      case ExperienceLevel.advanced:
        return 'מתקדם';
      case ExperienceLevel.expert:
        return 'מומחה';
    }
  }
}

enum WorkoutGoal {
  weightLoss,
  muscleGain,
  endurance,
  strength,
  flexibility,
  generalFitness;

  String get displayName {
    switch (this) {
      case WorkoutGoal.weightLoss:
        return 'ירידה במשקל';
      case WorkoutGoal.muscleGain:
        return 'עלייה במסה';
      case WorkoutGoal.endurance:
        return 'סיבולת';
      case WorkoutGoal.strength:
        return 'כוח';
      case WorkoutGoal.flexibility:
        return 'גמישות';
      case WorkoutGoal.generalFitness:
        return 'כושר כללי';
    }
  }
}

enum QuestionType {
  singleChoice,
  multipleChoice,
  number,
  slider,
  scale,
  text;

  String get displayName {
    switch (this) {
      case QuestionType.singleChoice:
        return 'בחירה יחידה';
      case QuestionType.multipleChoice:
        return 'בחירה מרובה';
      case QuestionType.number:
        return 'מספר';
      case QuestionType.slider:
        return 'סליידר';
      case QuestionType.scale:
        return 'סקלה';
      case QuestionType.text:
        return 'טקסט';
    }
  }
}

// ==============================================================================
// CORE MODELS
// ==============================================================================

/// מודל אחד ויחיד לסט תרגיל שמאחד את כל הצרכים
class ExerciseSet {
  final String id;
  final String? exerciseId; // לקישור להיסטוריה
  final String? workoutId; // לקישור לאימון
  final double? weight; // משקל בק"ג
  final int? reps; // מספר חזרות
  final SetType setType; // סוג הסט
  final bool isCompleted; // האם הושלם
  final String? notes; // הערות
  final DateTime date; // תאריך ביצוע
  final DateTime createdAt; // תאריך יצירה
  final int? restTime; // זמן מנוחה בשניות
  final int? tempo; // קצב (שניות)
  final double? estimatedOneRepMax; // 1RM משוער
  final int? rpe; // מדד מאמץ
  final int? rir; // חזרות עד כישלון
  final bool? pr; // שיא אישי (PR) – עזר

  ExerciseSet({
    required this.id,
    this.exerciseId,
    this.workoutId,
    this.weight,
    this.reps,
    this.setType = SetType.normal,
    this.isCompleted = false,
    this.notes,
    this.tempo,
    this.estimatedOneRepMax,
    this.rpe,
    this.rir,
    this.pr,
    DateTime? date,
    DateTime? createdAt,
    this.restTime,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  bool get isPR => pr ?? false;
  double get volume => (weight ?? 0) * (reps ?? 0);

  // עותק מעודכן
  ExerciseSet copyWith({
    String? id,
    String? exerciseId,
    String? workoutId,
    double? weight,
    int? reps,
    SetType? setType,
    bool? isCompleted,
    String? notes,
    DateTime? date,
    DateTime? createdAt,
    int? restTime,
    int? tempo,
    double? estimatedOneRepMax,
    int? rpe,
    int? rir,
    bool? pr,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      workoutId: workoutId ?? this.workoutId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      setType: setType ?? this.setType,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      restTime: restTime ?? this.restTime,
      tempo: tempo ?? this.tempo,
      estimatedOneRepMax: estimatedOneRepMax ?? this.estimatedOneRepMax,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      pr: pr ?? this.pr,
    );
  }

  // המרה ל-Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'workout_id': workoutId,
      'weight': weight,
      'reps': reps,
      'set_type': setType.name,
      'is_completed': isCompleted,
      'notes': notes,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'rest_time': restTime,
      'tempo': tempo,
      'estimated_one_rep_max': estimatedOneRepMax,
      'rpe': rpe,
      'rir': rir,
      'pr': pr,
    };
  }

  // יצירה מ-Map
  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] ?? '',
      exerciseId: map['exercise_id'],
      workoutId: map['workout_id'],
      weight: (map['weight'] as num?)?.toDouble(),
      reps: map['reps'] as int?,
      setType: map['set_type'] != null
          ? SetType.values.firstWhere(
              (e) => e.name == map['set_type'],
              orElse: () => SetType.normal,
            )
          : SetType.normal,
      isCompleted: map['is_completed'] ?? false,
      notes: map['notes'],
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      restTime: map['rest_time'] as int?,
      tempo: map['tempo'] as int?,
      estimatedOneRepMax: (map['estimated_one_rep_max'] as num?)?.toDouble(),
      rpe: map['rpe'] as int?,
      rir: map['rir'] as int?,
      pr: map['pr'] as bool?,
    );
  }

  // המרה ל-JSON (לתאימות לאחור)
  Map<String, dynamic> toJson() => toMap();
  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      ExerciseSet.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseSet &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.workoutId == workoutId &&
        other.weight == weight &&
        other.reps == reps &&
        other.setType == setType &&
        other.isCompleted == isCompleted &&
        other.notes == notes &&
        other.date == date &&
        other.createdAt == createdAt &&
        other.restTime == restTime &&
        other.tempo == tempo &&
        other.estimatedOneRepMax == estimatedOneRepMax &&
        other.rpe == rpe &&
        other.rir == rir &&
        other.pr == pr;
  }

  @override
  int get hashCode => Object.hash(
        id,
        exerciseId,
        workoutId,
        weight,
        reps,
        setType,
        isCompleted,
        notes,
        date,
        createdAt,
        restTime,
        tempo,
        estimatedOneRepMax,
        rpe,
        rir,
        pr,
      );
}

/// מודל לרקורד אישי
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

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'date': date.toIso8601String(),
      'set_id': setId,
      'type': type.name,
    };
  }

  factory PersonalRecord.fromMap(Map<String, dynamic> map) {
    return PersonalRecord(
      value: (map['value'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      setId: map['set_id'],
      type: PRType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PRType.weight,
      ),
    );
  }
}

/// מודל להיסטוריית תרגיל
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

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exerciseId,
      'sets': sets.map((e) => e.toMap()).toList(),
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'personal_records': personalRecords.map((e) => e.toMap()).toList(),
      'total_volume': totalVolume,
      'total_sets': totalSets,
    };
  }

  factory ExerciseHistory.fromMap(Map<String, dynamic> map) {
    return ExerciseHistory(
      exerciseId: map['exercise_id'] ?? '',
      sets: (map['sets'] as List? ?? [])
          .map((e) => ExerciseSet.fromMap(e as Map<String, dynamic>))
          .toList(),
      lastWorkoutDate: map['last_workout_date'] != null
          ? DateTime.parse(map['last_workout_date'])
          : null,
      personalRecords: (map['personal_records'] as List? ?? [])
          .map((e) => PersonalRecord.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalVolume: map['total_volume'] as int?,
      totalSets: map['total_sets'] as int?,
    );
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

  // ========== גטרים נדרשים ==========

  /// מספר מפגשים ייחודיים (לפי תאריך)
  int get totalSessions {
    final sessionDates =
        sets.map((s) => s.date.toIso8601String().substring(0, 10)).toSet();
    return sessionDates.length;
  }

  /// ממוצע משקל בכל הסטים
  double get averageWeight {
    final weights = sets.where((s) => s.weight != null).map((s) => s.weight!);
    if (weights.isEmpty) return 0.0;
    return weights.reduce((a, b) => a + b) / weights.length;
  }

  /// Personal Records
  PersonalRecord? get maxWeightPR {
    final prs = personalRecords.where((pr) => pr.type == PRType.weight);
    if (prs.isEmpty) return null;
    return prs.reduce((a, b) => a.value > b.value ? a : b);
  }

  PersonalRecord? get maxRepsPR {
    final prs = personalRecords.where((pr) => pr.type == PRType.reps);
    if (prs.isEmpty) return null;
    return prs.reduce((a, b) => a.value > b.value ? a : b);
  }

  PersonalRecord? get maxVolumePR {
    final prs = personalRecords.where((pr) => pr.type == PRType.volume);
    if (prs.isEmpty) return null;
    return prs.reduce((a, b) => a.value > b.value ? a : b);
  }

  PersonalRecord? get maxOneRMPR {
    final prs = personalRecords.where((pr) => pr.type == PRType.intensity);
    if (prs.isEmpty) return null;
    return prs.reduce((a, b) => a.value > b.value ? a : b);
  }

  // ========== סטטיסטיקות מהירות ==========

  // מחזיר מפה עם נתונים סטטיסטיים בסיסיים
  Map<String, dynamic> getStatistics() {
    final completedSets = sets.where((set) => set.isCompleted).toList();
    if (completedSets.isEmpty) return {};

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentSets =
        completedSets.where((set) => set.date.isAfter(thirtyDaysAgo));

    return {
      'total_sets': completedSets.length,
      'recent_sets': recentSets.length,
      'total_volume':
          completedSets.fold<double>(0, (sum, set) => sum + set.volume),
      'recent_volume':
          recentSets.fold<double>(0, (sum, set) => sum + set.volume),
      'avg_weight': completedSets.where((s) => s.weight != null).isNotEmpty
          ? completedSets
                  .where((s) => s.weight != null)
                  .fold<double>(0, (sum, set) => sum + set.weight!) /
              completedSets.where((s) => s.weight != null).length
          : 0,
      'avg_reps': completedSets.where((s) => s.reps != null).isNotEmpty
          ? completedSets
                  .where((s) => s.reps != null)
                  .fold<int>(0, (sum, set) => sum + set.reps!) /
              completedSets.where((s) => s.reps != null).length
          : 0,
    };
  }

  // סטטיסטיקות מתקדמות — כאן אפשר להרחיב
  Map<String, dynamic> getDetailedStatistics() {
    // כרגע פשוט מחזיר את getStatistics, בעתיד אפשר להוסיף חישובים נוספים
    return getStatistics();
  }

  // קבלת הסטים האחרונים
  List<ExerciseSet> getRecentSets(int count) {
    final sortedSets = List<ExerciseSet>.from(sets)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedSets.take(count).toList();
  }

  // קבלת רקורד אישי לפי סוג
  PersonalRecord? getPersonalRecord(PRType type) {
    final records = personalRecords.where((pr) => pr.type == type);
    if (records.isEmpty) return null;
    return records.reduce((a, b) => a.value > b.value ? a : b);
  }

  // עדכון רקורדים אישיים (לשימוש פנימי)
  void updatePersonalRecords(ExerciseSet set) {
    if (!set.isCompleted) return;

    final records = List<PersonalRecord>.from(personalRecords);
    bool updated = false;

    // בדיקת רקורד משקל
    if (set.weight != null) {
      final weightPR = getPersonalRecord(PRType.weight);
      if (weightPR == null || set.weight! > weightPR.value) {
        records.add(PersonalRecord(
          value: set.weight!,
          date: set.date,
          setId: set.id,
          type: PRType.weight,
        ));
        updated = true;
      }
    }

    // בדיקת רקורד חזרות
    if (set.reps != null) {
      final repsPR = getPersonalRecord(PRType.reps);
      if (repsPR == null || set.reps! > repsPR.value) {
        records.add(PersonalRecord(
          value: set.reps!.toDouble(),
          date: set.date,
          setId: set.id,
          type: PRType.reps,
        ));
        updated = true;
      }
    }

    // בדיקת רקורד נפח
    if (set.weight != null && set.reps != null) {
      final volume = set.volume;
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
    }

    if (updated) {
      personalRecords.clear();
      personalRecords.addAll(records);
    }
  }

  /// לקבלת טווח סטים בתאריכים (לשימוש בהשוואות)
  List<ExerciseSet> getSetsInDateRange(DateTime from, DateTime to) {
    return sets
        .where((s) => s.date.isAfter(from) && s.date.isBefore(to))
        .toList();
  }
}

/// מודל לתרגיל באימון
class ExerciseModel {
  final String id;
  final String exerciseId; // קישור לתרגיל הבסיסי
  final String name;
  final List<ExerciseSet> sets;
  final int? restTime; // זמן מנוחה בשניות בין סטים
  final String? notes;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.sets,
    this.restTime,
    this.notes,
    this.videoUrl,
  });

  ExerciseModel copyWith({
    String? id,
    String? exerciseId,
    String? name,
    List<ExerciseSet>? sets,
    int? restTime,
    String? notes,
    String? videoUrl,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'name': name,
      'sets': sets.map((e) => e.toMap()).toList(),
      'rest_time': restTime,
      'notes': notes,
      'video_url': videoUrl,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      exerciseId: map['exercise_id'] ?? '',
      name: map['name'] ?? '',
      sets: (map['sets'] as List? ?? [])
          .map((e) => ExerciseSet.fromMap(e as Map<String, dynamic>))
          .toList(),
      restTime: map['rest_time'] as int?,
      notes: map['notes'],
      videoUrl: map['video_url'],
    );
  }

  // תאימות לאחור
  Map<String, dynamic> toJson() => toMap();
  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      ExerciseModel.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseModel &&
        other.id == id &&
        other.exerciseId == exerciseId &&
        other.name == name &&
        listEquals(other.sets, sets) &&
        other.restTime == restTime &&
        other.notes == notes &&
        other.videoUrl == videoUrl;
  }

  @override
  int get hashCode => Object.hash(
        id,
        exerciseId,
        name,
        Object.hashAll(sets),
        restTime,
        notes,
        videoUrl,
      );
}

/// מודל לאימון
class WorkoutModel {
  final String id;
  final String title;
  final String? description;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final bool isTemplate;
  final DateTime? date;
  final bool isCompleted;
  final String? notes;
  final Map<String, dynamic>? metadata;

  WorkoutModel({
    required this.id,
    required this.title,
    this.description,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
    this.userId,
    this.isTemplate = false,
    this.date,
    this.isCompleted = false,
    this.notes,
    this.metadata,
  });

  // נתונים מחושבים
  int get totalSets =>
      exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);

  int get totalReps => exercises.fold(
      0,
      (sum, exercise) =>
          sum +
          exercise.sets.fold(0, (setSum, set) => setSum + (set.reps ?? 0)));

  double get totalVolume => exercises.fold(
      0.0,
      (sum, exercise) =>
          sum + exercise.sets.fold(0.0, (setSum, set) => setSum + set.volume));

  int get personalRecords => exercises.fold(
      0,
      (sum, exercise) =>
          sum +
          exercise.sets
              .where((set) => set.weight != null && set.weight! > 0)
              .length);

  WorkoutModel copyWith({
    String? id,
    String? title,
    String? description,
    List<ExerciseModel>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    bool? isTemplate,
    DateTime? date,
    bool? isCompleted,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isTemplate: isTemplate ?? this.isTemplate,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_id': userId,
      'is_template': isTemplate,
      'date': date?.toIso8601String(),
      'is_completed': isCompleted,
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      exercises: (map['exercises'] as List? ?? [])
          .map((e) => ExerciseModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt:
          DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
      userId: map['user_id'],
      isTemplate: map['is_template'] ?? false,
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      isCompleted: map['is_completed'] ?? false,
      notes: map['notes'],
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  // תאימות לאחור
  Map<String, dynamic> toJson() => toMap();
  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      WorkoutModel.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        listEquals(other.exercises, exercises) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.userId == userId &&
        other.isTemplate == isTemplate &&
        other.date == date &&
        other.isCompleted == isCompleted &&
        other.notes == notes &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        Object.hashAll(exercises),
        createdAt,
        updatedAt,
        userId,
        isTemplate,
        date,
        isCompleted,
        notes,
        metadata != null ? Object.hashAll(metadata!.entries) : null,
      );
}

extension PersonalRecordFormat on PersonalRecord {
  String get formattedValue {
    if (type == PRType.reps) return '${value.toInt()} חזרות';
    if (type == PRType.weight || type == PRType.intensity)
      return '${value.toStringAsFixed(1)} ק"ג';
    if (type == PRType.volume) return '${value.toStringAsFixed(0)} ק"ג נפח';
    return value.toString();
  }
}
