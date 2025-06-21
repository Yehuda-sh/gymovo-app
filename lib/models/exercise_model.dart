// lib/models/exercise_model.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum MuscleGroup {
  chest('חזה', '💪'),
  back('גב', '🔙'),
  shoulders('כתפיים', '🤷'),
  biceps('ביצפס', '💪'),
  triceps('טריצפס', '💪'),
  legs('רגליים', '🦵'),
  glutes('ישבן', '🍑'),
  core('בטן וליבה', '🏋️'),
  calves('שוקיים', '🦵'),
  forearms('אמות', '💪'),
  cardio('קרדיו', '❤️'),
  fullBody('גוף מלא', '🏋️‍♂️');

  const MuscleGroup(this.hebrewName, this.emoji);
  final String hebrewName;
  final String emoji;
}

enum ExerciseType {
  strength('כוח', Icons.fitness_center),
  cardio('קרדיו', Icons.directions_run),
  flexibility('גמישות', Icons.self_improvement),
  endurance('סיבולת', Icons.timer),
  balance('איזון', Icons.balance),
  plyometric('פליומטרי', Icons.hourglass_full),
  isometric('איזומטרי', Icons.pause),
  compound('מורכב', Icons.group_work),
  isolation('בידוד', Icons.center_focus_strong);

  const ExerciseType(this.hebrewName, this.icon);
  final String hebrewName;
  final IconData icon;
}

enum Equipment {
  none('ללא ציוד', '🏃'),
  barbell('מוט', '🏋️'),
  dumbbell('משקולת', '🏋️‍♀️'),
  kettlebell('קטלבל', '⚫'),
  machine('מכונה', '🔧'),
  cable('כבלים', '🔗'),
  bodyweight('משקל גוף', '🤸'),
  resistance('גומיות', '🎗️'),
  medicine('כדור רפואי', '⚽'),
  suspension('TRX', '🪢'),
  plate('דיסק', '⭕'),
  bench('ספסל', '🪑'),
  pullup('מתח', '🏗️'),
  other('אחר', '❓');

  const Equipment(this.hebrewName, this.emoji);
  final String hebrewName;
  final String emoji;
}

enum Difficulty {
  beginner('מתחיל', 1, Color(0xFF4CAF50)),
  intermediate('בינוני', 2, Color(0xFFFF9800)),
  advanced('מתקדם', 3, Color(0xFFF44336));

  const Difficulty(this.hebrewName, this.level, this.color);
  final String hebrewName;
  final int level;
  final Color color;
}

enum SetType {
  normal('רגיל'),
  warmup('חימום'),
  failure('כשל'),
  dropSet('דרופ סט'),
  restPause('מנוחה-הפסקה'),
  cluster('קלסטר'),
  tempo('טמפו'),
  pause('פאוז'),
  mechanical('מכני'),
  pyramid('פירמידה');

  const SetType(this.hebrewName);
  final String hebrewName;
}

enum RPE {
  veryEasy(6, 'קל מאוד', '😌'),
  easy(7, 'קל', '🙂'),
  moderate(8, 'בינוני', '😐'),
  hard(9, 'קשה', '😤'),
  veryHard(10, 'קשה מאוד', '🥵');

  const RPE(this.value, this.hebrewName, this.emoji);
  final int value;
  final String hebrewName;
  final String emoji;
}

class ExerciseMetadata {
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final ExerciseType type;
  final Equipment equipment;
  final Difficulty difficulty;
  final String? videoUrl;
  final List<String> instructions;
  final List<String> tips;
  final List<String> commonMistakes;
  final Map<String, dynamic> mechanics; // ROM, tempo guidelines, etc.

  ExerciseMetadata({
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.type,
    required this.equipment,
    required this.difficulty,
    this.videoUrl,
    this.instructions = const [],
    this.tips = const [],
    this.commonMistakes = const [],
    this.mechanics = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryMuscles': primaryMuscles.map((m) => m.name).toList(),
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'type': type.name,
      'equipment': equipment.name,
      'difficulty': difficulty.name,
      'videoUrl': videoUrl,
      'instructions': instructions,
      'tips': tips,
      'commonMistakes': commonMistakes,
      'mechanics': mechanics,
    };
  }

  factory ExerciseMetadata.fromJson(Map<String, dynamic> json) {
    return ExerciseMetadata(
      primaryMuscles: (json['primaryMuscles'] as List?)
              ?.map((name) => MuscleGroup.values.firstWhere(
                  (m) => m.name == name,
                  orElse: () => MuscleGroup.chest))
              .toList() ??
          [],
      secondaryMuscles: (json['secondaryMuscles'] as List?)
              ?.map((name) => MuscleGroup.values.firstWhere(
                  (m) => m.name == name,
                  orElse: () => MuscleGroup.chest))
              .toList() ??
          [],
      type: ExerciseType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ExerciseType.strength,
      ),
      equipment: Equipment.values.firstWhere(
        (e) => e.name == json['equipment'],
        orElse: () => Equipment.none,
      ),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      videoUrl: json['videoUrl'] as String?,
      instructions: List<String>.from(json['instructions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      commonMistakes: List<String>.from(json['commonMistakes'] ?? []),
      mechanics: Map<String, dynamic>.from(json['mechanics'] ?? {}),
    );
  }
}

class PerformanceMetrics {
  final double? volume; // weight × reps
  final double? intensity; // RPE or %1RM
  final double? density; // volume/time
  final int? timeUnderTension; // seconds
  final double? powerOutput; // for explosive movements
  final Map<String, dynamic> customMetrics;

  PerformanceMetrics({
    this.volume,
    this.intensity,
    this.density,
    this.timeUnderTension,
    this.powerOutput,
    this.customMetrics = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'volume': volume,
      'intensity': intensity,
      'density': density,
      'timeUnderTension': timeUnderTension,
      'powerOutput': powerOutput,
      'customMetrics': customMetrics,
    };
  }

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      volume: json['volume'] as double?,
      intensity: json['intensity'] as double?,
      density: json['density'] as double?,
      timeUnderTension: json['timeUnderTension'] as int?,
      powerOutput: json['powerOutput'] as double?,
      customMetrics: Map<String, dynamic>.from(json['customMetrics'] ?? {}),
    );
  }
}

class ExerciseSet {
  final String id;
  final int? reps;
  final double? weight; // in kg
  final int? restTime; // in seconds
  final bool isCompleted;
  final String? notes;
  final SetType setType;
  final RPE? rpe;
  final int? rir; // Reps in Reserve
  final DateTime? completedAt;
  final PerformanceMetrics? metrics;
  final bool isPR; // Personal Record
  final double? distance; // for cardio exercises
  final Duration? duration; // for time-based exercises
  final int? calories; // estimated calories burned

  ExerciseSet({
    required this.id,
    this.reps,
    this.weight,
    this.restTime,
    this.isCompleted = false,
    this.notes,
    this.setType = SetType.normal,
    this.rpe,
    this.rir,
    this.completedAt,
    this.metrics,
    this.isPR = false,
    this.distance,
    this.duration,
    this.calories,
  });

  // Calculated properties
  double get volume {
    if (weight != null && reps != null) {
      return weight! * reps!;
    }
    return 0.0;
  }

  double get estimatedOneRepMax {
    if (weight == null || reps == null || reps == 0) return 0.0;
    if (reps == 1) return weight!;

    // Brzycki formula: 1RM = weight / (1.0278 - (0.0278 × reps))
    return weight! / (1.0278 - (0.0278 * reps!));
  }

  String get intensityDescription {
    if (rpe != null) return '${rpe!.emoji} ${rpe!.hebrewName}';
    if (rir != null) return 'RIR $rir';
    return '';
  }

  bool get isCardio => distance != null || duration != null;
  bool get isStrength => weight != null && reps != null;
  bool get isTime => duration != null;

  // Create a copy of the set with some fields updated
  ExerciseSet copyWith({
    String? id,
    int? reps,
    double? weight,
    int? restTime,
    bool? isCompleted,
    String? notes,
    SetType? setType,
    RPE? rpe,
    int? rir,
    DateTime? completedAt,
    PerformanceMetrics? metrics,
    bool? isPR,
    double? distance,
    Duration? duration,
    int? calories,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      setType: setType ?? this.setType,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      completedAt: completedAt ?? this.completedAt,
      metrics: metrics ?? this.metrics,
      isPR: isPR ?? this.isPR,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
    );
  }

  // Convert set to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reps': reps,
      'weight': weight,
      'restTime': restTime,
      'isCompleted': isCompleted,
      'notes': notes,
      'setType': setType.name,
      'rpe': rpe?.value,
      'rir': rir,
      'completedAt': completedAt?.toIso8601String(),
      'metrics': metrics?.toJson(),
      'isPR': isPR,
      'distance': distance,
      'duration': duration?.inSeconds,
      'calories': calories,
    };
  }

  // Create set from JSON
  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      id: json['id'] as String,
      reps: json['reps'] as int?,
      weight: (json['weight'] as num?)?.toDouble(),
      restTime: json['restTime'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      setType: SetType.values.firstWhere(
        (type) => type.name == json['setType'],
        orElse: () => SetType.normal,
      ),
      rpe: json['rpe'] != null
          ? RPE.values.firstWhere((r) => r.value == json['rpe'])
          : null,
      rir: json['rir'] as int?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      metrics: json['metrics'] != null
          ? PerformanceMetrics.fromJson(json['metrics'])
          : null,
      isPR: json['isPR'] as bool? ?? false,
      distance: json['distance'] as double?,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      calories: json['calories'] as int?,
    );
  }

  // Create a new set with smart defaults
  factory ExerciseSet.create({
    int? reps,
    double? weight,
    int? restTime,
    String? notes,
    SetType setType = SetType.normal,
    RPE? rpe,
    int? rir,
    double? distance,
    Duration? duration,
  }) {
    return ExerciseSet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reps: reps,
      weight: weight,
      restTime: restTime,
      notes: notes,
      setType: setType,
      rpe: rpe,
      rir: rir,
      distance: distance,
      duration: duration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseSet && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    if (isCardio) {
      return 'ExerciseSet(distance: ${distance}km, duration: ${duration?.inMinutes}min)';
    }
    return 'ExerciseSet(weight: ${weight}kg, reps: $reps, volume: ${volume.toStringAsFixed(1)}kg)';
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final String? description;
  final List<ExerciseSet> sets;
  final int? restTime; // Default rest time in seconds between sets
  final String? notes;
  final ExerciseMetadata? metadata;
  final DateTime createdAt;
  final DateTime? lastPerformed;
  final bool isFavorite;
  final List<String> tags;
  final Map<String, dynamic> personalBests;
  final int timesPerformed;
  final double averageRating; // 1-5 stars
  final String? displayImage;
  final String? videoUrl;
  final List<String> instructions;
  final List<String> tips;
  final List<String> commonMistakes;
  final Map<String, dynamic> mechanics;

  ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    required this.sets,
    this.restTime,
    this.notes,
    this.metadata,
    DateTime? createdAt,
    this.lastPerformed,
    this.isFavorite = false,
    this.tags = const [],
    this.personalBests = const {},
    this.timesPerformed = 0,
    this.averageRating = 0.0,
    this.displayImage,
    this.videoUrl,
    this.instructions = const [],
    this.tips = const [],
    this.commonMistakes = const [],
    this.mechanics = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculated properties
  int get totalSets => sets.length;
  int get completedSets => sets.where((set) => set.isCompleted).length;
  double get completionRate => totalSets > 0 ? completedSets / totalSets : 0.0;

  double get totalVolume {
    return sets.fold(0.0, (sum, set) => sum + set.volume);
  }

  Duration get estimatedDuration {
    final setTime = 30; // Average seconds per set
    final restTimeTotal = (sets.length - 1) * (restTime ?? 60);
    final totalSeconds = (sets.length * setTime) + restTimeTotal;
    return Duration(seconds: totalSeconds);
  }

  List<MuscleGroup> get muscleGroups {
    return metadata?.primaryMuscles ?? [];
  }

  ExerciseType get exerciseType {
    return metadata?.type ?? ExerciseType.strength;
  }

  Equipment get equipment {
    return metadata?.equipment ?? Equipment.none;
  }

  Difficulty get difficulty {
    return metadata?.difficulty ?? Difficulty.beginner;
  }

  bool get hasPersonalRecords => personalBests.isNotEmpty;

  String get primaryMuscleDisplay {
    if (muscleGroups.isNotEmpty) {
      return '${muscleGroups.first.emoji} ${muscleGroups.first.hebrewName}';
    }
    return '💪 לא צוין';
  }

  // Performance analysis
  Map<String, dynamic> getPerformanceAnalysis() {
    final completedSets = sets.where((set) => set.isCompleted).toList();
    if (completedSets.isEmpty) return {};

    final weights = completedSets.map((set) => set.weight ?? 0).toList();
    final reps = completedSets.map((set) => set.reps ?? 0).toList();
    final volumes = completedSets.map((set) => set.volume).toList();

    return {
      'avgWeight': weights.isNotEmpty
          ? weights.reduce((a, b) => a + b) / weights.length
          : 0,
      'maxWeight': weights.isNotEmpty ? weights.reduce(max) : 0,
      'avgReps':
          reps.isNotEmpty ? reps.reduce((a, b) => a + b) / reps.length : 0,
      'maxReps': reps.isNotEmpty ? reps.reduce(max) : 0,
      'totalVolume': volumes.reduce((a, b) => a + b),
      'avgVolume': volumes.reduce((a, b) => a + b) / volumes.length,
      'maxVolume': volumes.reduce(max),
      'estimated1RM':
          completedSets.map((set) => set.estimatedOneRepMax).reduce(max),
      'completionRate': completionRate,
      'intensityDistribution': _getIntensityDistribution(completedSets),
    };
  }

  Map<String, int> _getIntensityDistribution(List<ExerciseSet> sets) {
    final distribution = <String, int>{};
    for (final set in sets) {
      if (set.rpe != null) {
        final key = set.rpe!.hebrewName;
        distribution[key] = (distribution[key] ?? 0) + 1;
      }
    }
    return distribution;
  }

  // Smart suggestions
  ExerciseSet getSuggestedNextSet() {
    if (sets.isEmpty) {
      return ExerciseSet.create(
        reps: 10,
        weight: equipment == Equipment.bodyweight ? null : 20.0,
        restTime: restTime,
      );
    }

    final lastSet = sets.last;
    if (lastSet.isCompleted) {
      // Progressive overload logic
      if (lastSet.reps != null && lastSet.reps! >= 12) {
        // Increase weight, decrease reps
        return lastSet.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          weight: lastSet.weight != null ? lastSet.weight! + 2.5 : null,
          reps: max(8, lastSet.reps! - 2),
          isCompleted: false,
        );
      } else {
        // Same weight, try more reps
        return lastSet.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          reps: lastSet.reps != null ? lastSet.reps! + 1 : null,
          isCompleted: false,
        );
      }
    }

    return lastSet.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isCompleted: false,
    );
  }

  // Create a copy of the exercise with some fields updated
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? description,
    List<ExerciseSet>? sets,
    int? restTime,
    String? notes,
    ExerciseMetadata? metadata,
    DateTime? createdAt,
    DateTime? lastPerformed,
    bool? isFavorite,
    List<String>? tags,
    Map<String, dynamic>? personalBests,
    int? timesPerformed,
    double? averageRating,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      personalBests: personalBests ?? this.personalBests,
      timesPerformed: timesPerformed ?? this.timesPerformed,
      averageRating: averageRating ?? this.averageRating,
      displayImage: displayImage ?? this.displayImage,
      videoUrl: videoUrl ?? this.videoUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      mechanics: mechanics ?? this.mechanics,
    );
  }

  // Convert exercise to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sets': sets.map((e) => e.toJson()).toList(),
      'restTime': restTime,
      'notes': notes,
      'metadata': metadata?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastPerformed': lastPerformed?.toIso8601String(),
      'isFavorite': isFavorite,
      'tags': tags,
      'personalBests': personalBests,
      'timesPerformed': timesPerformed,
      'averageRating': averageRating,
    };
  }

  // Create exercise from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sets: (json['sets'] as List)
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      restTime: json['restTime'] as int?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] != null
          ? ExerciseMetadata.fromJson(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastPerformed: json['lastPerformed'] != null
          ? DateTime.parse(json['lastPerformed'] as String)
          : null,
      isFavorite: json['isFavorite'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      personalBests: Map<String, dynamic>.from(json['personalBests'] ?? {}),
      timesPerformed: json['timesPerformed'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Create a new exercise with smart defaults
  factory ExerciseModel.create({
    required String name,
    String? description,
    List<ExerciseSet> sets = const [],
    int? restTime,
    String? notes,
    ExerciseMetadata? metadata,
    List<String> tags = const [],
  }) {
    // Smart default rest time based on exercise type
    int defaultRestTime = 60;
    if (metadata != null) {
      switch (metadata.type) {
        case ExerciseType.strength:
          defaultRestTime =
              metadata.difficulty == Difficulty.advanced ? 180 : 120;
          break;
        case ExerciseType.cardio:
          defaultRestTime = 30;
          break;
        case ExerciseType.endurance:
          defaultRestTime = 45;
          break;
        default:
          defaultRestTime = 60;
      }
    }

    return ExerciseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      sets: sets,
      restTime: restTime ?? defaultRestTime,
      notes: notes,
      metadata: metadata,
      tags: tags,
    );
  }

  // Factory for common exercises
  factory ExerciseModel.squat({int sets = 3, int reps = 10, double? weight}) {
    return ExerciseModel.create(
      name: 'סקוואט',
      description: 'תרגיל יסוד לחיזוק הרגליים והישבן',
      sets: List.generate(
          sets,
          (index) => ExerciseSet.create(
                reps: reps,
                weight: weight,
                restTime: 120,
              )),
      metadata: ExerciseMetadata(
        primaryMuscles: [MuscleGroup.legs, MuscleGroup.glutes],
        secondaryMuscles: [MuscleGroup.core],
        type: ExerciseType.compound,
        equipment: weight != null ? Equipment.barbell : Equipment.bodyweight,
        difficulty: Difficulty.intermediate,
        instructions: [
          'עמוד עם הרגליים ברוחב הכתפיים',
          'שמור על הגב ישר והחזה פתוח',
          'רד עד שהירכיים מקבילות לרצפה',
          'חזור למצב הזקיפה בכוח'
        ],
        tips: [
          'התחיל עם משקל גוף בלבד',
          'שמור על הברכיים מעל הקרסוליים',
          'נשום פנימה ירידה, החוצה עלייה'
        ],
      ),
      tags: ['רגליים', 'יסוד', 'מורכב'],
    );
  }

  factory ExerciseModel.pushUp({int sets = 3, int reps = 15}) {
    return ExerciseModel.create(
      name: 'שכיבות סמיכה',
      description: 'תרגיל מעולה לחיזוק החזה, הכתפיים והטריצפס',
      sets: List.generate(
          sets,
          (index) => ExerciseSet.create(
                reps: reps,
                restTime: 60,
              )),
      metadata: ExerciseMetadata(
        primaryMuscles: [MuscleGroup.chest],
        secondaryMuscles: [
          MuscleGroup.shoulders,
          MuscleGroup.triceps,
          MuscleGroup.core
        ],
        type: ExerciseType.compound,
        equipment: Equipment.bodyweight,
        difficulty: Difficulty.beginner,
        instructions: [
          'התחל במצב פלנק עם הידיים ברוחב הכתפיים',
          'רד עד שהחזה כמעט נוגע ברצפה',
          'דחף חזרה למצב ההתחלה',
          'שמור על הגוף ישר לאורך כל התנועה'
        ],
        tips: [
          'התחיל על הברכיים אם קשה',
          'שמור על הזרועות קרובות לגוף',
          'נשום פנימה ירידה, החוצה עלייה'
        ],
      ),
      tags: ['חזה', 'משקל גוף', 'יסוד'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ExerciseModel(id: $id, name: $name, sets: ${sets.length}, muscle: $primaryMuscleDisplay)';
  }
}
