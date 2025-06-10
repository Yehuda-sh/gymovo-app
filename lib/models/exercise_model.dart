import 'package:flutter/foundation.dart';

class ExerciseModel {
  final String id;
  final String name;
  final List<ExerciseSet> sets;
  final int? restTime; // Rest time in seconds between sets
  final String? notes;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.sets,
    this.restTime,
    this.notes,
  });

  // Create a copy of the exercise with some fields updated
  ExerciseModel copyWith({
    String? id,
    String? name,
    List<ExerciseSet>? sets,
    int? restTime,
    String? notes,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
    );
  }

  // Convert exercise to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets.map((e) => e.toJson()).toList(),
      'restTime': restTime,
      'notes': notes,
    };
  }

  // Create exercise from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sets: (json['sets'] as List)
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      restTime: json['restTime'] as int?,
      notes: json['notes'] as String?,
    );
  }

  // Create a new exercise
  factory ExerciseModel.create({
    required String name,
    List<ExerciseSet> sets = const [],
    int? restTime,
    String? notes,
  }) {
    return ExerciseModel(
      id: '', // Will be set by the server
      name: name,
      sets: sets,
      restTime: restTime,
      notes: notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseModel &&
        other.id == id &&
        other.name == name &&
        listEquals(other.sets, sets) &&
        other.restTime == restTime &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, Object.hashAll(sets), restTime, notes);
  }
}

class ExerciseSet {
  final String id;
  final int? reps;
  final double? weight; // in kg
  final int? restTime; // in seconds
  final bool isCompleted;
  final String? notes;

  ExerciseSet({
    required this.id,
    this.reps,
    this.weight,
    this.restTime,
    this.isCompleted = false,
    this.notes,
  });

  // Create a copy of the set with some fields updated
  ExerciseSet copyWith({
    String? id,
    int? reps,
    double? weight,
    int? restTime,
    bool? isCompleted,
    String? notes,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
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
    );
  }

  // Create a new set
  factory ExerciseSet.create({
    int? reps,
    double? weight,
    int? restTime,
    String? notes,
  }) {
    return ExerciseSet(
      id: '', // Will be set by the server
      reps: reps,
      weight: weight,
      restTime: restTime,
      notes: notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseSet &&
        other.id == id &&
        other.reps == reps &&
        other.weight == weight &&
        other.restTime == restTime &&
        other.isCompleted == isCompleted &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(id, reps, weight, restTime, isCompleted, notes);
  }
}
