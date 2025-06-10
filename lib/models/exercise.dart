import 'package:flutter/foundation.dart';

enum ExerciseDifficulty {
  beginner,
  easy,
  medium,
  hard,
  advanced;

  String get name => toString().split('.').last;
}

enum ExerciseEquipment {
  bodyweight,
  dumbbell,
  barbell,
  kettlebell,
  machine,
  cable,
  resistanceBand,
  trx,
  mat,
  abWheel,
  pullupBar,
  pushupBars,
  other;

  String get name => toString().split('.').last;
}

extension ExerciseDifficultyExtension on ExerciseDifficulty {
  static const Map<String, Map<String, String>> _translations = {
    'beginner': {'he': 'מתחילים', 'en': 'Beginner'},
    'easy': {'he': 'קל', 'en': 'Easy'},
    'medium': {'he': 'בינוני', 'en': 'Medium'},
    'hard': {'he': 'קשה', 'en': 'Hard'},
    'advanced': {'he': 'מתקדם', 'en': 'Advanced'},
  };

  String getDisplayName(String languageCode) {
    return _translations[name]?[languageCode] ?? name;
  }

  int get numericValue {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return 1;
      case ExerciseDifficulty.easy:
        return 2;
      case ExerciseDifficulty.medium:
        return 3;
      case ExerciseDifficulty.hard:
        return 4;
      case ExerciseDifficulty.advanced:
        return 5;
    }
  }
}

extension ExerciseDifficultyStaticExtension on ExerciseDifficulty {
  static ExerciseDifficulty fromNumericValue(int value) {
    switch (value) {
      case 1:
        return ExerciseDifficulty.beginner;
      case 2:
        return ExerciseDifficulty.easy;
      case 3:
        return ExerciseDifficulty.medium;
      case 4:
        return ExerciseDifficulty.hard;
      case 5:
        return ExerciseDifficulty.advanced;
      default:
        return ExerciseDifficulty.medium;
    }
  }

  static ExerciseDifficulty fromString(String value) {
    return ExerciseDifficulty.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ExerciseDifficulty.medium,
    );
  }
}

extension ExerciseEquipmentExtension on ExerciseEquipment {
  static const Map<String, Map<String, String>> _translations = {
    'bodyweight': {'he': 'משקל גוף', 'en': 'Bodyweight'},
    'dumbbell': {'he': 'דמבל', 'en': 'Dumbbell'},
    'barbell': {'he': 'מוט', 'en': 'Barbell'},
    'kettlebell': {'he': 'כדור משקולות', 'en': 'Kettlebell'},
    'machine': {'he': 'מכונה', 'en': 'Machine'},
    'cable': {'he': 'כבל', 'en': 'Cable'},
    'resistanceBand': {'he': 'רצועת התנגדות', 'en': 'Resistance Band'},
    'trx': {'he': 'רצועות TRX', 'en': 'TRX'},
    'mat': {'he': 'מזרן אימון', 'en': 'Training Mat'},
    'abWheel': {'he': 'גלגל בטן', 'en': 'Ab Wheel'},
    'pullupBar': {'he': 'מוט מתח', 'en': 'Pull-up Bar'},
    'pushupBars': {'he': 'פומית שכיבות שמיכה', 'en': 'Push-up Bars'},
    'other': {'he': 'אחר', 'en': 'Other'},
  };

  String getDisplayName(String languageCode) {
    return _translations[name]?[languageCode] ?? name;
  }

  List<ExerciseDifficulty> get suitableDifficulties {
    switch (this) {
      case ExerciseEquipment.bodyweight:
      case ExerciseEquipment.resistanceBand:
      case ExerciseEquipment.mat:
        return [
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium
        ];
      case ExerciseEquipment.dumbbell:
      case ExerciseEquipment.kettlebell:
      case ExerciseEquipment.cable:
      case ExerciseEquipment.trx:
        return [
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard
        ];
      case ExerciseEquipment.barbell:
      case ExerciseEquipment.machine:
      case ExerciseEquipment.pullupBar:
      case ExerciseEquipment.pushupBars:
      case ExerciseEquipment.abWheel:
        return [
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.advanced
        ];
      case ExerciseEquipment.other:
        return ExerciseDifficulty.values;
    }
  }

  static ExerciseEquipment fromString(String value) {
    return ExerciseEquipment.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ExerciseEquipment.other,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String nameHe; // Hebrew name
  final String? description;
  final String? descriptionHe; // Hebrew description
  final List<String> instructions;
  final List<String> instructionsHe; // Hebrew instructions
  final String? imageUrl;
  final String? videoUrl;
  final String? category;
  final String? equipment;
  final String? difficulty;
  final Map<String, dynamic>? metadata;

  Exercise({
    required this.id,
    required this.name,
    required this.nameHe,
    this.description,
    this.descriptionHe,
    required this.instructions,
    required this.instructionsHe,
    this.imageUrl,
    this.videoUrl,
    this.category,
    this.equipment,
    this.difficulty,
    this.metadata,
  });

  // Create a copy of the exercise with some fields updated
  Exercise copyWith({
    String? id,
    String? name,
    String? nameHe,
    String? description,
    String? descriptionHe,
    List<String>? instructions,
    List<String>? instructionsHe,
    String? imageUrl,
    String? videoUrl,
    String? category,
    String? equipment,
    String? difficulty,
    Map<String, dynamic>? metadata,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      nameHe: nameHe ?? this.nameHe,
      description: description ?? this.description,
      descriptionHe: descriptionHe ?? this.descriptionHe,
      instructions: instructions ?? this.instructions,
      instructionsHe: instructionsHe ?? this.instructionsHe,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      category: category ?? this.category,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      metadata: metadata ?? this.metadata,
    );
  }

  // Convert exercise to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameHe': nameHe,
      'description': description,
      'descriptionHe': descriptionHe,
      'instructions': instructions,
      'instructionsHe': instructionsHe,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'category': category,
      'equipment': equipment,
      'difficulty': difficulty,
      'metadata': metadata,
    };
  }

  // Create exercise from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      nameHe: json['nameHe'] as String,
      description: json['description'] as String?,
      descriptionHe: json['descriptionHe'] as String?,
      instructions: (json['instructions'] as List).cast<String>(),
      instructionsHe: (json['instructionsHe'] as List).cast<String>(),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      category: json['category'] as String?,
      equipment: json['equipment'] as String?,
      difficulty: json['difficulty'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // Create a new exercise
  factory Exercise.create({
    required String name,
    required String nameHe,
    String? description,
    String? descriptionHe,
    List<String> instructions = const [],
    List<String> instructionsHe = const [],
    String? imageUrl,
    String? videoUrl,
    String? category,
    String? equipment,
    String? difficulty,
    Map<String, dynamic>? metadata,
  }) {
    return Exercise(
      id: '', // Will be set by the server
      name: name,
      nameHe: nameHe,
      description: description,
      descriptionHe: descriptionHe,
      instructions: instructions,
      instructionsHe: instructionsHe,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      category: category,
      equipment: equipment,
      difficulty: difficulty,
      metadata: metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
        other.id == id &&
        other.name == name &&
        other.nameHe == nameHe &&
        other.description == description &&
        other.descriptionHe == descriptionHe &&
        listEquals(other.instructions, instructions) &&
        listEquals(other.instructionsHe, instructionsHe) &&
        other.imageUrl == imageUrl &&
        other.videoUrl == videoUrl &&
        other.category == category &&
        other.equipment == equipment &&
        other.difficulty == difficulty &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      nameHe,
      description,
      descriptionHe,
      Object.hashAll(instructions),
      Object.hashAll(instructionsHe),
      imageUrl,
      videoUrl,
      category,
      equipment,
      difficulty,
      metadata != null ? Object.hashAll(metadata!.entries) : null,
    );
  }
}
