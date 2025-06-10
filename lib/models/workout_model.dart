import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String title;
  final String? description;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId;
  final bool isTemplate;

  WorkoutModel({
    required this.id,
    required this.title,
    this.description,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
    this.userId,
    this.isTemplate = false,
  });

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
    );
  }

  // Create a new workout
  factory WorkoutModel.create({
    required String title,
    String? description,
    List<ExerciseModel> exercises = const [],
    String? userId,
    bool isTemplate = false,
  }) {
    return WorkoutModel(
      id: '', // Will be set by the server
      title: title,
      description: description,
      exercises: exercises,
      createdAt: DateTime.now(),
      userId: userId,
      isTemplate: isTemplate,
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
        other.isTemplate == isTemplate;
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
    );
  }
}

class ExerciseModel {
  final String id;
  final String name;
  final List<ExerciseSet> sets;
  final String? notes;
  final String? videoUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    this.notes,
    this.videoUrl,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sets: (map['sets'] as List? ?? [])
          .map((s) => ExerciseSet.fromMap(s as Map<String, dynamic>))
          .toList(),
      notes: map['notes'],
      videoUrl: map['video_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets.map((s) => s.toMap()).toList(),
      'notes': notes,
      'video_url': videoUrl,
    };
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    List<ExerciseSet>? sets,
    String? notes,
    String? videoUrl,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      videoUrl: videoUrl ?? this.videoUrl,
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

  ExerciseSet({
    required this.id,
    this.weight,
    this.reps,
    this.restTime,
    this.isCompleted = false,
    this.notes,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      reps: map['reps'],
      restTime: map['rest_time'],
      isCompleted: map['is_completed'] ?? false,
      notes: map['notes'],
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
    };
  }

  ExerciseSet copyWith({
    String? id,
    double? weight,
    int? reps,
    int? restTime,
    bool? isCompleted,
    String? notes,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
