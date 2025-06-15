// lib/models/week_plan_model.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'workout_model.dart';

/// Metadata keys for WeekPlanModel
enum WeekPlanMetadataKey {
  weeklyGoal,
  coachNotes,
  userNotes,
  weeklySummary,
  achievements,
}

class WeekPlanModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<WorkoutModel> workouts;
  final bool isActive;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? metadata;

  WeekPlanModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.workouts,
    this.isActive = true,
    this.lastUpdated,
    this.metadata,
  }) : assert(
            startDate.isBefore(endDate), 'Start date must be before end date');

  factory WeekPlanModel.fromMap(Map<String, dynamic> map) {
    try {
      // Handle metadata conversion
      Map<String, dynamic>? parsedMetadata;
      if (map['metadata'] != null) {
        if (map['metadata'] is Map<String, dynamic>) {
          parsedMetadata = Map<String, dynamic>.from(map['metadata']);
        } else if (map['metadata'] is String &&
            map['metadata'].toString().isNotEmpty) {
          try {
            final decoded = json.decode(map['metadata'].toString());
            if (decoded is Map<String, dynamic>) {
              parsedMetadata = decoded;
            } else {
              debugPrint('Warning: metadata is not a valid map: $decoded');
              parsedMetadata = null;
            }
          } catch (e) {
            debugPrint('Error parsing metadata JSON: $e');
            parsedMetadata = null;
          }
        }
      }

      return WeekPlanModel(
        id: map['id'] ?? '',
        userId: map['user_id'] ?? '',
        title: map['title'] ?? '',
        description: map['description'] ?? '',
        startDate: DateTime.parse(map['start_date']),
        endDate: DateTime.parse(map['end_date']),
        workouts: (map['workouts'] as List?)
                ?.map((e) => WorkoutModel.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        isActive: map['is_active'] ?? true,
        lastUpdated: map['last_updated'] != null
            ? DateTime.parse(map['last_updated'])
            : null,
        metadata: parsedMetadata,
      );
    } catch (e) {
      throw FormatException('Invalid date format in WeekPlanModel: $e');
    }
  }

  Map<String, dynamic> toMap() {
    final result = {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'workouts': workouts.map((workout) => workout.toMap()).toList(),
      'is_active': isActive,
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };

    // Remove null values if needed for API compatibility
    // result.removeWhere((k, v) => v == null);
    return result;
  }

  WeekPlanModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<WorkoutModel>? workouts,
    bool? isActive,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return WeekPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workouts: workouts ?? this.workouts,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  static WeekPlanModel empty() {
    return WeekPlanModel(
      id: '',
      userId: '',
      title: '',
      description: '',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
      workouts: [],
      isActive: false,
    );
  }

  bool get isEmpty => id.isEmpty;

  bool get isValidRange => startDate.isBefore(endDate);

  bool get isCurrentWeek {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  int get totalWorkouts => workouts.length;

  int get completedWorkouts => workouts.where((w) => w.isCompleted).length;

  /// Returns completion percentage as a value between 0 and 1
  double get completionPercentage {
    if (totalWorkouts == 0) return 0;
    return completedWorkouts / totalWorkouts;
  }

  /// Returns completion percentage as a value between 0 and 100
  double get completionPercentageAsPercentage => completionPercentage * 100;

  WorkoutModel? getCurrentWorkout() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      return workouts.firstWhere(
        (workout) =>
            workout.date != null &&
            workout.date!.year == today.year &&
            workout.date!.month == today.month &&
            workout.date!.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  WorkoutModel? getNextWorkout() {
    final now = DateTime.now();
    try {
      return workouts.firstWhere(
        (workout) => workout.date != null && workout.date!.isAfter(now),
        orElse: () => throw Exception('No future workouts found'),
      );
    } catch (e) {
      return null;
    }
  }

  WorkoutModel? getLastCompletedWorkout() {
    try {
      return workouts
          .where((workout) => workout.isCompleted && workout.date != null)
          .reduce((a, b) => a.date!.isAfter(b.date!) ? a : b);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> getWeeklySummary() {
    final completedWorkouts = workouts.where((w) => w.isCompleted);
    double totalSets = 0;
    double totalReps = 0;
    double totalVolume = 0;
    List<int> personalRecords = [];

    for (final workout in completedWorkouts) {
      totalSets += workout.totalSets.toDouble();
      totalReps += workout.totalReps.toDouble();
      totalVolume += workout.totalVolume;
      personalRecords.add(workout.personalRecords);
    }

    return {
      'total_workouts': completedWorkouts.length,
      'total_sets': totalSets.toInt(),
      'total_reps': totalReps.toInt(),
      'total_volume': totalVolume,
      'personal_records': personalRecords,
      'completion_percentage': completionPercentage,
    };
  }

  // Metadata helpers with null safety
  String? getWeeklyGoal() =>
      metadata?[WeekPlanMetadataKey.weeklyGoal.name] as String?;
  String? getCoachNotes() =>
      metadata?[WeekPlanMetadataKey.coachNotes.name] as String?;
  String? getUserNotes() =>
      metadata?[WeekPlanMetadataKey.userNotes.name] as String?;
  Map<String, dynamic>? getWeeklySummaryMetadata() =>
      metadata?[WeekPlanMetadataKey.weeklySummary.name]
          as Map<String, dynamic>?;
  List<String>? getAchievements() =>
      metadata?[WeekPlanMetadataKey.achievements.name] as List<String>?;
}
