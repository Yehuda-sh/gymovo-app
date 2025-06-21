// lib/models/exercise.dart
import 'package:flutter/material.dart';

/// רמות קושי לתרגילים
enum ExerciseDifficulty {
  beginner, // מתחיל
  easy, // קל
  medium, // בינוני
  hard, // קשה
  advanced, // מתקדם
}

/// Extension לרמות קושי
extension ExerciseDifficultyLevel on ExerciseDifficulty {
  int get level {
    switch (this) {
      case ExerciseDifficulty.advanced:
        return 5;
      case ExerciseDifficulty.easy:
        return 1;
      case ExerciseDifficulty.beginner:
        return 2;
      case ExerciseDifficulty.medium:
        return 3;
      case ExerciseDifficulty.hard:
        return 4;
    }
  }
}

extension ExerciseDifficultyExtension on ExerciseDifficulty {
  /// מפת תרגומים לכל רמת קושי
  static const Map<String, Map<String, String>> _translations = {
    'beginner': {
      'he': 'מתחיל',
      'en': 'Beginner',
    },
    'easy': {
      'he': 'קל',
      'en': 'Easy',
    },
    'medium': {
      'he': 'בינוני',
      'en': 'Medium',
    },
    'hard': {
      'he': 'קשה',
      'en': 'Hard',
    },
    'advanced': {
      'he': 'מתקדם',
      'en': 'Advanced',
    },
  };

  /// קבלת שם לתצוגה לפי שפה
  String getDisplayName(String languageCode) {
    final translation = _translations[name];
    if (translation != null && translation.containsKey(languageCode)) {
      return translation[languageCode]!;
    }
    return name; // fallback לשם המקורי
  }

  /// שם בעברית
  String get hebrewName => getDisplayName('he');

  /// שם באנגלית
  String get englishName => getDisplayName('en');

  /// ערך מספרי לרמת הקושי
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

  /// צבע מתאים לרמת הקושי
  Color get color {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return Colors.green;
      case ExerciseDifficulty.easy:
        return Colors.lightGreen;
      case ExerciseDifficulty.medium:
        return Colors.orange;
      case ExerciseDifficulty.hard:
        return Colors.deepOrange;
      case ExerciseDifficulty.advanced:
        return Colors.red;
    }
  }

  /// אייקון מתאים לרמת הקושי
  IconData get icon {
    switch (this) {
      case ExerciseDifficulty.beginner:
        return Icons.star_border;
      case ExerciseDifficulty.easy:
        return Icons.star_half;
      case ExerciseDifficulty.medium:
        return Icons.star;
      case ExerciseDifficulty.hard:
        return Icons.stars;
      case ExerciseDifficulty.advanced:
        return Icons.military_tech;
    }
  }
}

/// Extension סטטי לרמות קושי
extension ExerciseDifficultyStaticExtension on ExerciseDifficulty {
  /// יצירת רמת קושי מערך מספרי
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
        return ExerciseDifficulty.medium; // ברירת מחדל
    }
  }
}

/// סוגי ציוד לתרגילים
enum ExerciseEquipment {
  bodyweight, // משקל גוף
  dumbbell, // דמבל
  barbell, // מוט מתכת
  kettlebell, // קטלבל
  resistanceBand, // רצועת התנגדות
  pullupBar, // מוט מתח
  machine, // מכונה
  cable, // כבלים
  medicine, // כדור רפואי
  bosuBall, // כדור בוסו
  foam, // גליל קצף
  plate, // דיסק משקל
  other, // אחר
}

/// Extension לסוגי ציוד
extension ExerciseEquipmentExtension on ExerciseEquipment {
  /// מפת תרגומים לכל סוג ציוד
  static const Map<String, Map<String, String>> _translations = {
    'bodyweight': {
      'he': 'משקל גוף',
      'en': 'Bodyweight',
    },
    'dumbbell': {
      'he': 'דמבל',
      'en': 'Dumbbell',
    },
    'barbell': {
      'he': 'מוט מתכת',
      'en': 'Barbell',
    },
    'kettlebell': {
      'he': 'קטלבל',
      'en': 'Kettlebell',
    },
    'resistanceBand': {
      'he': 'רצועת התנגדות',
      'en': 'Resistance Band',
    },
    'pullupBar': {
      'he': 'מוט מתח',
      'en': 'Pull-up Bar',
    },
    'machine': {
      'he': 'מכונה',
      'en': 'Machine',
    },
    'cable': {
      'he': 'כבלים',
      'en': 'Cable',
    },
    'medicine': {
      'he': 'כדור רפואי',
      'en': 'Medicine Ball',
    },
    'bosuBall': {
      'he': 'כדור בוסו',
      'en': 'Bosu Ball',
    },
    'foam': {
      'he': 'גליל קצף',
      'en': 'Foam Roller',
    },
    'plate': {
      'he': 'דיסק משקל',
      'en': 'Weight Plate',
    },
    'other': {
      'he': 'אחר',
      'en': 'Other',
    },
  };

  /// קבלת שם לתצוגה לפי שפה
  String getDisplayName(String languageCode) {
    final translation = _translations[name];
    if (translation != null && translation.containsKey(languageCode)) {
      return translation[languageCode]!;
    }
    return name; // fallback לשם המקורי
  }

  /// שם בעברית
  String get hebrewName => getDisplayName('he');

  /// שם באנגלית
  String get englishName => getDisplayName('en');

  /// רמות קושי מתאימות לציוד
  List<ExerciseDifficulty> get suitableDifficulties {
    switch (this) {
      case ExerciseEquipment.bodyweight:
        return [
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
        ];
      case ExerciseEquipment.dumbbell:
        return [
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
        ];
      case ExerciseEquipment.barbell:
        return [
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.advanced,
        ];
      case ExerciseEquipment.kettlebell:
        return [
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
        ];
      case ExerciseEquipment.resistanceBand:
        return [
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
        ];
      case ExerciseEquipment.pullupBar:
        return [
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.advanced,
        ];
      case ExerciseEquipment.machine:
        return [
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
        ];
      case ExerciseEquipment.cable:
        return [
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
        ];
      case ExerciseEquipment.medicine:
        return [
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
        ];
      case ExerciseEquipment.bosuBall:
        return [
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.advanced,
        ];
      case ExerciseEquipment.foam:
        return [
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.easy,
        ];
      case ExerciseEquipment.plate:
        return [
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.advanced,
        ];
      case ExerciseEquipment.other:
        return ExerciseDifficulty.values; // כל הרמות
    }
  }

  /// אייקון מתאים לציוד
  IconData get icon {
    switch (this) {
      case ExerciseEquipment.bodyweight:
        return Icons.accessibility_new;
      case ExerciseEquipment.dumbbell:
        return Icons.fitness_center;
      case ExerciseEquipment.barbell:
        return Icons.fitness_center;
      case ExerciseEquipment.kettlebell:
        return Icons.sports_gymnastics;
      case ExerciseEquipment.resistanceBand:
        return Icons.linear_scale;
      case ExerciseEquipment.pullupBar:
        return Icons.horizontal_rule;
      case ExerciseEquipment.machine:
        return Icons.precision_manufacturing;
      case ExerciseEquipment.cable:
        return Icons.cable;
      case ExerciseEquipment.medicine:
        return Icons.sports_volleyball;
      case ExerciseEquipment.bosuBall:
        return Icons.circle;
      case ExerciseEquipment.foam:
        return Icons.straighten;
      case ExerciseEquipment.plate:
        return Icons.album;
      case ExerciseEquipment.other:
        return Icons.build;
    }
  }
}

/// סוגי תרגילים
enum ExerciseType {
  strength, // כוח
  cardio, // אירובי
  flexibility, // גמישות
  endurance, // סיבולת
  compound, // מורכב
  isolation, // בידוד
  plyometric, // פליומטרי
  isometric, // איזומטרי
}

/// Extension לסוגי תרגילים
extension ExerciseTypeExtension on ExerciseType {
  /// שם בעברית
  String get hebrewName {
    switch (this) {
      case ExerciseType.strength:
        return 'כוח';
      case ExerciseType.cardio:
        return 'אירובי';
      case ExerciseType.flexibility:
        return 'גמישות';
      case ExerciseType.endurance:
        return 'סיבולת';
      case ExerciseType.compound:
        return 'מורכב';
      case ExerciseType.isolation:
        return 'בידוד';
      case ExerciseType.plyometric:
        return 'פליומטרי';
      case ExerciseType.isometric:
        return 'איזומטרי';
    }
  }

  /// שם באנגלית
  String get englishName {
    switch (this) {
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.endurance:
        return 'Endurance';
      case ExerciseType.compound:
        return 'Compound';
      case ExerciseType.isolation:
        return 'Isolation';
      case ExerciseType.plyometric:
        return 'Plyometric';
      case ExerciseType.isometric:
        return 'Isometric';
    }
  }

  /// צבע מתאים לסוג התרגיל
  Color get color {
    switch (this) {
      case ExerciseType.strength:
        return Colors.red;
      case ExerciseType.cardio:
        return Colors.blue;
      case ExerciseType.flexibility:
        return Colors.green;
      case ExerciseType.endurance:
        return Colors.orange;
      case ExerciseType.compound:
        return Colors.purple;
      case ExerciseType.isolation:
        return Colors.teal;
      case ExerciseType.plyometric:
        return Colors.amber;
      case ExerciseType.isometric:
        return Colors.indigo;
    }
  }

  /// אייקון מתאים לסוג התרגיל
  IconData get icon {
    switch (this) {
      case ExerciseType.strength:
        return Icons.fitness_center;
      case ExerciseType.cardio:
        return Icons.favorite;
      case ExerciseType.flexibility:
        return Icons.self_improvement;
      case ExerciseType.endurance:
        return Icons.timer;
      case ExerciseType.compound:
        return Icons.group_work;
      case ExerciseType.isolation:
        return Icons.center_focus_strong;
      case ExerciseType.plyometric:
        return Icons.trending_up;
      case ExerciseType.isometric:
        return Icons.pause;
    }
  }
}

/// קבוצות שרירים
enum MuscleGroup {
  fullBody, // כל הגוף
  chest, // חזה
  back, // גב
  shoulders, // כתפיים
  biceps, // ביצפס
  triceps, // טריצפס
  forearms, // אמות
  core, // ליבה
  abs, // בטן
  legs, // רגליים
  quads, // ארבע ראשי
  hamstrings, // אחורי הירך
  glutes, // ישבן
  calves, // שוקיים
  cardio, // לב ריאות
  lats, // רחבי גב
  traps, // טרפז
}

/// Extension לקבוצות שרירים
extension MuscleGroupExtension on MuscleGroup {
  /// שם בעברית
  String get hebrewName {
    switch (this) {
      case MuscleGroup.fullBody:
        return 'כל הגוף';
      case MuscleGroup.chest:
        return 'חזה';
      case MuscleGroup.back:
        return 'גב';
      case MuscleGroup.shoulders:
        return 'כתפיים';
      case MuscleGroup.biceps:
        return 'ביצפס';
      case MuscleGroup.triceps:
        return 'טריצפס';
      case MuscleGroup.forearms:
        return 'אמות';
      case MuscleGroup.core:
        return 'ליבה';
      case MuscleGroup.abs:
        return 'בטן';
      case MuscleGroup.legs:
        return 'רגליים';
      case MuscleGroup.quads:
        return 'ארבע ראשי';
      case MuscleGroup.hamstrings:
        return 'אחורי הירך';
      case MuscleGroup.glutes:
        return 'ישבן';
      case MuscleGroup.calves:
        return 'שוקיים';
      case MuscleGroup.cardio:
        return 'לב ריאות';
      case MuscleGroup.lats:
        return 'רחבי גב';
      case MuscleGroup.traps:
        return 'טרפז';
    }
  }

  /// שם באנגלית
  String get englishName {
    switch (this) {
      case MuscleGroup.fullBody:
        return 'Full Body';
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.abs:
        return 'Abs';
      case MuscleGroup.legs:
        return 'Legs';
      case MuscleGroup.quads:
        return 'Quadriceps';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.cardio:
        return 'Cardio';
      case MuscleGroup.lats:
        return 'Lats';
      case MuscleGroup.traps:
        return 'Traps';
    }
  }

  /// צבע מתאים לקבוצת השרירים
  Color get color {
    switch (this) {
      case MuscleGroup.fullBody:
        return Colors.purple;
      case MuscleGroup.chest:
        return Colors.red;
      case MuscleGroup.back:
        return Colors.green;
      case MuscleGroup.shoulders:
        return Colors.orange;
      case MuscleGroup.biceps:
        return Colors.blue;
      case MuscleGroup.triceps:
        return Colors.indigo;
      case MuscleGroup.forearms:
        return Colors.cyan;
      case MuscleGroup.core:
        return Colors.amber;
      case MuscleGroup.abs:
        return Colors.yellow;
      case MuscleGroup.legs:
        return Colors.brown;
      case MuscleGroup.quads:
        return Colors.deepOrange;
      case MuscleGroup.hamstrings:
        return Colors.lime;
      case MuscleGroup.glutes:
        return Colors.pink;
      case MuscleGroup.calves:
        return Colors.teal;
      case MuscleGroup.cardio:
        return Colors.red;
      case MuscleGroup.lats:
        return Colors.lightGreen;
      case MuscleGroup.traps:
        return Colors.deepPurple;
    }
  }

  /// אייקון מתאים לקבוצת השרירים
  IconData get icon {
    switch (this) {
      case MuscleGroup.fullBody:
        return Icons.accessibility_new;
      case MuscleGroup.chest:
        return Icons.fitness_center;
      case MuscleGroup.back:
        return Icons.accessibility;
      case MuscleGroup.shoulders:
        return Icons.sports_martial_arts;
      case MuscleGroup.biceps:
        return Icons.sports_gymnastics;
      case MuscleGroup.triceps:
        return Icons.sports_gymnastics;
      case MuscleGroup.forearms:
        return Icons.back_hand;
      case MuscleGroup.core:
        return Icons.center_focus_strong;
      case MuscleGroup.abs:
        return Icons.filter_center_focus;
      case MuscleGroup.legs:
        return Icons.directions_walk;
      case MuscleGroup.quads:
        return Icons.directions_run;
      case MuscleGroup.hamstrings:
        return Icons.directions_walk;
      case MuscleGroup.glutes:
        return Icons.airline_seat_recline_normal;
      case MuscleGroup.calves:
        return Icons.hiking;
      case MuscleGroup.cardio:
        return Icons.favorite;
      case MuscleGroup.lats:
        return Icons.expand;
      case MuscleGroup.traps:
        return Icons.keyboard_arrow_up;
    }
  }
}

/// מחלקה ראשית לתרגיל
class Exercise {
  final String id;
  final String name;
  final String nameHe;
  final String description;
  final String descriptionHe;
  final List<String> instructions;
  final List<String> instructionsHe;
  final ExerciseType type;
  final ExerciseEquipment equipment;
  final ExerciseDifficulty difficulty;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final List<String> tags;
  final String displayImage;
  final String? videoUrl;
  final bool isVerified;
  final double rating;
  final int ratingCount;
  final Map<String, dynamic>? metadata;
  final bool isFavorite;
  final DateTime? createdAt;
  final Set<String> selectedIds;

  Exercise({
    required this.id,
    required this.name,
    required this.nameHe,
    required this.description,
    required this.descriptionHe,
    required this.instructions,
    required this.instructionsHe,
    required this.type,
    required this.equipment,
    required this.difficulty,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    this.tags = const [],
    this.displayImage = '',
    this.videoUrl,
    this.isVerified = false,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.metadata,
    this.isFavorite = false,
    this.createdAt,
    this.selectedIds = const {},
  });

  /// בדיקה אם התרגיל מתאים לחיפוש
  bool matchesQuery(String query, String language) {
    if (query.isEmpty) return true;

    final searchTerms = query.toLowerCase().split(' ');

    for (final term in searchTerms) {
      bool matchesTerm = false;

      // חיפוש בשם
      if (language == 'he') {
        matchesTerm = nameHe.toLowerCase().contains(term) ||
            descriptionHe.toLowerCase().contains(term);
      } else {
        matchesTerm = name.toLowerCase().contains(term) ||
            description.toLowerCase().contains(term);
      }

      // חיפוש בתגיות
      if (!matchesTerm) {
        matchesTerm = tags.any((tag) => tag.toLowerCase().contains(term));
      }

      // חיפוש בקבוצות שרירים
      if (!matchesTerm) {
        if (language == 'he') {
          matchesTerm = primaryMuscles.any(
                  (muscle) => muscle.hebrewName.toLowerCase().contains(term)) ||
              secondaryMuscles.any(
                  (muscle) => muscle.hebrewName.toLowerCase().contains(term));
        } else {
          matchesTerm = primaryMuscles.any((muscle) =>
                  muscle.englishName.toLowerCase().contains(term)) ||
              secondaryMuscles.any(
                  (muscle) => muscle.englishName.toLowerCase().contains(term));
        }
      }

      // חיפוש בציוד וקושי
      if (!matchesTerm) {
        if (language == 'he') {
          matchesTerm = equipment.hebrewName.toLowerCase().contains(term) ||
              difficulty.hebrewName.toLowerCase().contains(term) ||
              type.hebrewName.toLowerCase().contains(term);
        } else {
          matchesTerm = equipment.englishName.toLowerCase().contains(term) ||
              difficulty.englishName.toLowerCase().contains(term) ||
              type.englishName.toLowerCase().contains(term);
        }
      }

      if (!matchesTerm) return false;
    }

    return true;
  }

  /// Factory method ללחיצות דחיפה
  factory Exercise.pushUp() {
    return Exercise(
      id: 'pushup_001',
      name: 'Push-up',
      nameHe: 'לחיצות דחיפה',
      description: 'Classic upper body exercise',
      descriptionHe: 'תרגיל קלאסי לחלק העליון',
      instructions: [
        'Start in plank position',
        'Lower body until chest nearly touches floor',
        'Push back up to starting position'
      ],
      instructionsHe: [
        'התחל במצב פלאנק',
        'הורד את הגוף עד שהחזה כמעט נוגע ברצפה',
        'דחף בחזרה למצב ההתחלה'
      ],
      type: ExerciseType.strength,
      equipment: ExerciseEquipment.bodyweight,
      difficulty: ExerciseDifficulty.easy,
      primaryMuscles: [MuscleGroup.chest, MuscleGroup.triceps],
      secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.core],
      tags: ['חזה', 'טריצפס', 'משקל גוף', 'בסיסי'],
      isVerified: true,
      rating: 4.5,
      ratingCount: 1200,
    );
  }

  /// Factory method לסקוואטים
  factory Exercise.squat() {
    return Exercise(
      id: 'squat_001',
      name: 'Squat',
      nameHe: 'סקוואט',
      description: 'Fundamental leg exercise',
      descriptionHe: 'תרגיל יסוד לרגליים',
      instructions: [
        'Stand with feet shoulder-width apart',
        'Lower body as if sitting back into chair',
        'Keep knees aligned over toes',
        'Return to standing position'
      ],
      instructionsHe: [
        'עמוד עם רגליים ברוחב הכתפיים',
        'הורד את הגוף כאילו יושב על כיסא',
        'שמור על הברכיים מעל הבהונות',
        'חזור למצב עמידה'
      ],
      type: ExerciseType.compound,
      equipment: ExerciseEquipment.bodyweight,
      difficulty: ExerciseDifficulty.easy,
      primaryMuscles: [MuscleGroup.legs, MuscleGroup.glutes],
      secondaryMuscles: [MuscleGroup.core],
      tags: ['רגליים', 'ישבן', 'משקל גוף', 'מורכב'],
      isVerified: true,
      rating: 4.7,
      ratingCount: 950,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameHe': nameHe,
      'description': description,
      'descriptionHe': descriptionHe,
      'instructions': instructions,
      'instructionsHe': instructionsHe,
      'type': type.name,
      'equipment': equipment.name,
      'difficulty': difficulty.name,
      'primaryMuscles': primaryMuscles.map((m) => m.name).toList(),
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'tags': tags,
      'displayImage': displayImage,
      'videoUrl': videoUrl,
      'isVerified': isVerified,
      'rating': rating,
      'ratingCount': ratingCount,
      'metadata': metadata,
    };
  }

  /// JSON deserialization
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameHe: json['nameHe'] ?? '',
      description: json['description'] ?? '',
      descriptionHe: json['descriptionHe'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      instructionsHe: List<String>.from(json['instructionsHe'] ?? []),
      type: ExerciseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExerciseType.strength,
      ),
      equipment: ExerciseEquipment.values.firstWhere(
        (e) => e.name == json['equipment'],
        orElse: () => ExerciseEquipment.bodyweight,
      ),
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ExerciseDifficulty.medium,
      ),
      primaryMuscles: (json['primaryMuscles'] as List? ?? [])
          .map((name) => MuscleGroup.values.firstWhere(
                (m) => m.name == name,
                orElse: () => MuscleGroup.fullBody,
              ))
          .toList(),
      secondaryMuscles: (json['secondaryMuscles'] as List? ?? [])
          .map((name) => MuscleGroup.values.firstWhere(
                (m) => m.name == name,
                orElse: () => MuscleGroup.fullBody,
              ))
          .toList(),
      tags: List<String>.from(json['tags'] ?? []),
      displayImage: json['displayImage'] ?? '',
      videoUrl: json['videoUrl'],
      isVerified: json['isVerified'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// העתקה עם שינויים
  Exercise copyWith({
    String? id,
    String? name,
    String? nameHe,
    String? description,
    String? descriptionHe,
    List<String>? instructions,
    List<String>? instructionsHe,
    ExerciseType? type,
    ExerciseEquipment? equipment,
    ExerciseDifficulty? difficulty,
    List<MuscleGroup>? primaryMuscles,
    List<MuscleGroup>? secondaryMuscles,
    List<String>? tags,
    String? displayImage,
    String? videoUrl,
    bool? isVerified,
    double? rating,
    int? ratingCount,
    Map<String, dynamic>? metadata,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      nameHe: nameHe ?? this.nameHe,
      description: description ?? this.description,
      descriptionHe: descriptionHe ?? this.descriptionHe,
      instructions: instructions ?? this.instructions,
      instructionsHe: instructionsHe ?? this.instructionsHe,
      type: type ?? this.type,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      tags: tags ?? this.tags,
      displayImage: displayImage ?? this.displayImage,
      videoUrl: videoUrl ?? this.videoUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      metadata: metadata ?? this.metadata,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Exercise(id: $id, nameHe: $nameHe, difficulty: ${difficulty.hebrewName})';
  }
}
