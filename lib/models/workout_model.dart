import 'exercise_model.dart';
import 'package:flutter/foundation.dart';

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

  // Computed properties
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
          sum +
          exercise.sets.fold(0.0,
              (setSum, set) => setSum + ((set.weight ?? 0) * (set.reps ?? 0))));
  int get personalRecords => exercises.fold(
      0,
      (sum, exercise) =>
          sum +
          exercise.sets
              .where((set) => set.weight != null && set.weight! > 0)
              .length);

  // Create a copy of the workout with some fields updated
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

  // Convert workout to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'isTemplate': isTemplate,
      'date': date?.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Create workout from Map
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      exercises: (map['exercises'] as List)
          .map((e) => ExerciseModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      userId: map['userId'] as String?,
      isTemplate: map['isTemplate'] as bool? ?? false,
      date: map['date'] != null ? DateTime.parse(map['date'] as String) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      notes: map['notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  // Convert workout to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'isTemplate': isTemplate,
      'date': date?.toIso8601String(),
      'isCompleted': isCompleted,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Create workout from JSON
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      userId: json['userId'] as String?,
      isTemplate: json['isTemplate'] as bool? ?? false,
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Create a new workout
  factory WorkoutModel.create({
    required String title,
    String? description,
    List<ExerciseModel> exercises = const [],
    String? userId,
    bool isTemplate = false,
    DateTime? date,
    bool isCompleted = false,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return WorkoutModel(
      id: '', // Will be set by the server
      title: title,
      description: description,
      exercises: exercises,
      createdAt: DateTime.now(),
      userId: userId,
      isTemplate: isTemplate,
      date: date,
      isCompleted: isCompleted,
      notes: notes,
      metadata: metadata,
    );
  }

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
  int get hashCode {
    return Object.hash(
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
}

class ExerciseModel {
  final String id;
  final String name;
  final List<ExerciseSet> sets;
  final String? notes;
  final String? videoUrl;
  final int? restTime;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    this.notes,
    this.videoUrl,
    this.restTime,
  });

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
      'notes': notes,
      'video_url': videoUrl,
      'rest_time': restTime,
    };
  }

  // Add fromJson method
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sets: (json['sets'] as List? ?? [])
          .map((s) => ExerciseSet.fromMap(s as Map<String, dynamic>))
          .toList(),
      notes: json['notes'],
      videoUrl: json['video_url'],
      restTime: json['rest_time'],
    );
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sets: (map['sets'] as List? ?? [])
          .map((s) => ExerciseSet.fromMap(s as Map<String, dynamic>))
          .toList(),
      notes: map['notes'],
      videoUrl: map['video_url'],
      restTime: map['rest_time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
      'notes': notes,
      'video_url': videoUrl,
      'rest_time': restTime,
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    List<ExerciseSet>? sets,
    String? notes,
    String? videoUrl,
    int? restTime,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      videoUrl: videoUrl ?? this.videoUrl,
      restTime: restTime ?? this.restTime,
    );
  }
}

class ExerciseSet {
  final String id;
  final double? weight;
  final int? reps;
  final int? restTime;
  final bool isCompleted;
  final String? notes;
  final String? setType;
  final String? workoutId;

  ExerciseSet({
    required this.id,
    this.weight,
    this.reps,
    this.restTime,
    this.isCompleted = false,
    this.notes,
    this.setType,
    this.workoutId,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      reps: map['reps'],
      restTime: map['rest_time'],
      isCompleted: map['is_completed'] ?? false,
      notes: map['notes'],
      setType: map['set_type'],
      workoutId: map['workout_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'reps': reps,
      'rest_time': restTime,
      'is_completed': isCompleted,
      'notes': notes,
      'set_type': setType,
      'workout_id': workoutId,
    };
  }

  ExerciseSet copyWith({
    String? id,
    double? weight,
    int? reps,
    int? restTime,
    bool? isCompleted,
    String? notes,
    String? setType,
    String? workoutId,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      setType: setType ?? this.setType,
      workoutId: workoutId ?? this.workoutId,
    );
  }
}
