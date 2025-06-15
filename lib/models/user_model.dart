// lib/models/user_model.dart
import 'dart:math';
import 'exercise_history.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? nickname;
  final String? imageUrl;
  final int? age;
  final Gender? gender;
  final UserPreferences? preferences;
  final Map<String, dynamic>? questionnaireAnswers;
  final DateTime? lastWorkoutDate;
  final int workoutStreak;
  final int totalWorkouts;
  final List<WorkoutHistory> workoutHistory;
  final bool isProfileComplete;
  final DateTime? profileLastUpdated;
  final bool isGuest;
  final bool isDemo;
  final List<NicknameSuggestion>? nicknameSuggestions;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.nickname,
    this.imageUrl,
    this.isGuest = false,
    this.isDemo = false,
    this.age,
    this.gender,
    this.preferences,
    this.questionnaireAnswers,
    this.lastWorkoutDate,
    this.workoutStreak = 0,
    this.totalWorkouts = 0,
    this.workoutHistory = const [],
    this.isProfileComplete = false,
    this.profileLastUpdated,
    this.nicknameSuggestions,
  });

  // Create an empty user
  static UserModel empty() {
    return UserModel(
      id: '',
      email: '',
      name: '',
      nickname: null,
      imageUrl: null,
      isGuest: true,
      isDemo: false,
      age: null,
      gender: null,
      preferences: null,
      questionnaireAnswers: null,
      lastWorkoutDate: null,
      workoutStreak: 0,
      totalWorkouts: 0,
      workoutHistory: [],
      isProfileComplete: false,
      profileLastUpdated: null,
      nicknameSuggestions: null,
    );
  }

  // Check if user is empty
  bool get isEmpty => id.isEmpty;

  // Check if user is not empty
  bool get isNotEmpty => !isEmpty;

  // בנאי מ־Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    debugPrint('=== DEBUG: UserModel.fromMap called ===');
    debugPrint('Input map keys: ${map.keys.toList()}');
    debugPrint(
        'questionnaire_answers in input map: ${map['questionnaire_answers']}');
    debugPrint(
        'questionnaire_answers type: ${map['questionnaire_answers'].runtimeType}');

    Map<String, dynamic>? questionnaireAnswers;
    if (map['questionnaire_answers'] != null) {
      debugPrint('Processing questionnaire_answers...');
      final rawValue = map['questionnaire_answers'];
      debugPrint('Raw value: $rawValue');
      debugPrint('Raw value type: ${rawValue.runtimeType}');

      if (rawValue is Map<String, dynamic>) {
        questionnaireAnswers = rawValue;
        debugPrint('questionnaire_answers is already Map<String, dynamic>');
      } else if (rawValue is Map) {
        // Convert Map to Map<String, dynamic>
        questionnaireAnswers = Map<String, dynamic>.from(rawValue);
        debugPrint('questionnaire_answers converted from generic Map');
      } else if (rawValue is String) {
        try {
          final decoded = json.decode(rawValue);
          if (decoded is Map) {
            questionnaireAnswers = Map<String, dynamic>.from(decoded);
            debugPrint('questionnaire_answers decoded from JSON string');
          } else {
            debugPrint(
                'ERROR: Decoded JSON is not a Map: ${decoded.runtimeType}');
            questionnaireAnswers = null;
          }
        } catch (e) {
          debugPrint('Error decoding questionnaire_answers JSON: $e');
          debugPrint('Raw string value: $rawValue');
          questionnaireAnswers = null;
        }
      } else {
        debugPrint(
            'ERROR: Unexpected questionnaire_answers type: ${rawValue.runtimeType}');
        debugPrint('Attempting to convert to string and decode...');
        try {
          final decoded = json.decode(rawValue.toString());
          if (decoded is Map) {
            questionnaireAnswers = Map<String, dynamic>.from(decoded);
            debugPrint(
                'questionnaire_answers successfully decoded from toString()');
          } else {
            debugPrint('ERROR: Decoded value is not a Map');
            questionnaireAnswers = null;
          }
        } catch (e) {
          debugPrint('Final attempt failed: $e');
          questionnaireAnswers = null;
        }
      }
    } else {
      debugPrint('questionnaire_answers is null in map');
    }

    debugPrint('Final questionnaireAnswers: $questionnaireAnswers');
    debugPrint('=========================================');

    // Support both snake_case and camelCase field names
    final isGuest = map['is_guest'] ?? map['isGuest'] ?? false;
    final isDemo = map['is_demo'] ?? map['isDemo'] ?? false;

    // Convert workout history
    List<WorkoutHistory> workoutHistoryList = [];
    final rawWorkoutHistory = map['workout_history'] ?? map['workoutHistory'];
    if (rawWorkoutHistory != null) {
      if (rawWorkoutHistory is List) {
        workoutHistoryList = rawWorkoutHistory
            .map((w) {
              if (w is WorkoutHistory) return w;
              if (w is Map<String, dynamic>) return WorkoutHistory.fromMap(w);
              if (w is String) {
                try {
                  return WorkoutHistory.fromMap(json.decode(w));
                } catch (e) {
                  debugPrint('Error parsing workout history from string: $e');
                  return null;
                }
              }
              return null;
            })
            .whereType<WorkoutHistory>()
            .toList();
      }
    }

    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      nickname: map['nickname'],
      imageUrl: map['image_url'] ?? map['imageUrl'],
      age: map['age'],
      gender:
          map['gender'] != null ? _parseGender(map['gender'].toString()) : null,
      isGuest: isGuest,
      isDemo: isDemo,
      preferences: map['preferences'] != null
          ? UserPreferences.fromMap(map['preferences'] is Map<String, dynamic>
              ? map['preferences']
              : json.decode(map['preferences'].toString()))
          : null,
      questionnaireAnswers: questionnaireAnswers,
      lastWorkoutDate: map['last_workout_date'] != null
          ? DateTime.parse(map['last_workout_date'].toString())
          : map['lastWorkoutDate'] != null
              ? DateTime.parse(map['lastWorkoutDate'].toString())
              : null,
      workoutStreak: map['workout_streak'] ?? map['workoutStreak'] ?? 0,
      totalWorkouts: map['total_workouts'] ?? map['totalWorkouts'] ?? 0,
      workoutHistory: workoutHistoryList,
      isProfileComplete:
          map['is_profile_complete'] ?? map['isProfileComplete'] ?? false,
      profileLastUpdated: map['profile_last_updated'] != null
          ? DateTime.parse(map['profile_last_updated'].toString())
          : map['profileLastUpdated'] != null
              ? DateTime.parse(map['profileLastUpdated'].toString())
              : null,
      nicknameSuggestions: (map['nickname_suggestions'] ??
                  map['nicknameSuggestions'] as List?)
              ?.map((n) => NicknameSuggestion.fromMap(
                  n is Map<String, dynamic> ? n : json.decode(n.toString())))
              .toList(),
    );
  }

  // המרה ל־Map
  Map<String, dynamic> toMap() {
    debugPrint('=== DEBUG: UserModel.toMap called ===');
    debugPrint(
        'questionnaireAnswers before serialization: $questionnaireAnswers');
    debugPrint(
        'questionnaireAnswers type: ${questionnaireAnswers.runtimeType}');

    final map = {
      'id': id,
      'email': email,
      'name': name,
      'nickname': nickname,
      'image_url': imageUrl,
      'age': age,
      'gender': gender?.name,
      'is_guest': isGuest,
      'is_demo': isDemo,
      'preferences': preferences?.toMap(),
      'questionnaire_answers': questionnaireAnswers,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'workout_streak': workoutStreak,
      'total_workouts': totalWorkouts,
      'workout_history': workoutHistory.map((w) => w.toMap()).toList(),
      'is_profile_complete': isProfileComplete,
      'profile_last_updated': profileLastUpdated?.toIso8601String(),
      'nickname_suggestions':
          nicknameSuggestions?.map((n) => n.toMap()).toList(),
    };

    debugPrint(
        'questionnaire_answers in output map: ${map['questionnaire_answers']}');
    debugPrint('Output map keys: ${map.keys.toList()}');
    debugPrint('======================================');

    return map;
  }

  // יצירת עותק מעודכן
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? nickname,
    String? imageUrl,
    int? age,
    Gender? gender,
    UserPreferences? preferences,
    Map<String, dynamic>? questionnaireAnswers,
    DateTime? lastWorkoutDate,
    int? workoutStreak,
    int? totalWorkouts,
    List<WorkoutHistory>? workoutHistory,
    bool? isProfileComplete,
    DateTime? profileLastUpdated,
    List<NicknameSuggestion>? nicknameSuggestions,
    bool? isGuest,
    bool? isDemo,
  }) {
    debugPrint('=== DEBUG: UserModel.copyWith called ===');
    debugPrint('Current questionnaireAnswers: ${this.questionnaireAnswers}');
    debugPrint('New questionnaireAnswers parameter: $questionnaireAnswers');

    final newQuestionnaireAnswers =
        questionnaireAnswers ?? this.questionnaireAnswers;
    debugPrint('Final questionnaireAnswers to use: $newQuestionnaireAnswers');
    debugPrint('==========================================');

    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      imageUrl: imageUrl ?? this.imageUrl,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      isGuest: isGuest ?? this.isGuest,
      isDemo: isDemo ?? this.isDemo,
      preferences: preferences ?? this.preferences,
      questionnaireAnswers: newQuestionnaireAnswers,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      workoutHistory: workoutHistory ?? this.workoutHistory,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      profileLastUpdated: profileLastUpdated ?? this.profileLastUpdated,
      nicknameSuggestions: nicknameSuggestions ?? this.nicknameSuggestions,
    );
  }

  // Add helper methods for profile completion
  bool get hasRequiredProfileInfo {
    return age != null && gender != null && preferences != null;
  }

  bool get hasProfileImage {
    return imageUrl != null && imageUrl!.isNotEmpty;
  }

  bool get hasNickname {
    return nickname != null && nickname!.isNotEmpty;
  }

  // Add method to generate suggested nicknames
  List<NicknameSuggestion> generateSuggestedNicknames() {
    final List<String> prefixes = [
      'האריה',
      'הנמר',
      'הנשר',
      'הבולדוזר',
      'הטייגר'
    ];
    final List<String> suffixes = ['המהיר', 'החזק', 'המהולל', 'המנצח', 'האלוף'];
    final List<String> englishPrefixes = [
      'Iron',
      'Steel',
      'Power',
      'Fit',
      'Pro'
    ];
    final List<String> englishSuffixes = [
      'Master',
      'Champion',
      'Warrior',
      'Legend',
      'Hero'
    ];

    final random = Random();
    final List<NicknameSuggestion> suggestions = [];

    // Generate Hebrew nicknames
    for (int i = 0; i < 3; i++) {
      final prefix = prefixes[random.nextInt(prefixes.length)];
      final suffix = suffixes[random.nextInt(suffixes.length)];
      suggestions.add(NicknameSuggestion(
        nickname: '$prefix $suffix',
        isHebrew: true,
        isApproved: false,
      ));
    }

    // Generate English nicknames
    for (int i = 0; i < 3; i++) {
      final prefix = englishPrefixes[random.nextInt(englishPrefixes.length)];
      final suffix = englishSuffixes[random.nextInt(englishSuffixes.length)];
      suggestions.add(NicknameSuggestion(
        nickname: '$prefix$suffix',
        isHebrew: false,
        isApproved: false,
      ));
    }

    return suggestions;
  }

  // Add method to get default avatar based on gender and age
  String get defaultAvatarPath {
    if (gender == Gender.female) {
      if (age != null && age! < 30) {
        return 'assets/avatars/default_young_female.png';
      } else if (age != null && age! < 50) {
        return 'assets/avatars/default_middle_aged_female.png';
      } else {
        return 'assets/avatars/default_older_female.png';
      }
    } else if (gender == Gender.male) {
      if (age != null && age! < 30) {
        return 'assets/avatars/default_young_male.png';
      } else if (age != null && age! < 50) {
        return 'assets/avatars/default_middle_aged_male.png';
      } else {
        return 'assets/avatars/default_older_male.png';
      }
    }
    return 'assets/avatars/default_neutral.png';
  }

  // Add method to get display name (nickname or full name)
  String get displayName {
    return nickname ?? name;
  }

  // Add method to get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 5; // age, gender, preferences, nickname, questionnaire

    if (age != null) completedFields++;
    if (gender != null) completedFields++;
    if (preferences != null) completedFields++;
    if (hasNickname) completedFields++;
    if (questionnaireAnswers != null && questionnaireAnswers!.isNotEmpty) {
      completedFields++;
    }

    return completedFields / totalFields;
  }

  static Gender _parseGender(String value) {
    switch (value.toLowerCase()) {
      case 'female':
      case 'נקבה':
      case 'אישה':
        return Gender.female;
      case 'male':
      case 'זכר':
      case 'גבר':
        return Gender.male;
      default:
        return Gender.other;
    }
  }
}

class NicknameSuggestion {
  final String nickname;
  final bool isHebrew;
  final bool isApproved;
  final DateTime? approvedAt;

  NicknameSuggestion({
    required this.nickname,
    required this.isHebrew,
    this.isApproved = false,
    this.approvedAt,
  });

  factory NicknameSuggestion.fromMap(Map<String, dynamic> map) {
    return NicknameSuggestion(
      nickname: map['nickname'],
      isHebrew: map['is_hebrew'] ?? false,
      isApproved: map['is_approved'] ?? false,
      approvedAt: map['approved_at'] != null
          ? DateTime.parse(map['approved_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'is_hebrew': isHebrew,
      'is_approved': isApproved,
      'approved_at': approvedAt?.toIso8601String(),
    };
  }

  NicknameSuggestion copyWith({
    String? nickname,
    bool? isHebrew,
    bool? isApproved,
    DateTime? approvedAt,
  }) {
    return NicknameSuggestion(
      nickname: nickname ?? this.nickname,
      isHebrew: isHebrew ?? this.isHebrew,
      isApproved: isApproved ?? this.isApproved,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}

class UserPreferences {
  final String? workoutTime;
  final String? workoutDuration;
  final List<String>? equipment;
  final WorkoutGoal? goal;
  final ExperienceLevel? experienceLevel;
  final String? healthIssues;
  final List<String>? workoutDays;
  final int? preferredDuration;
  final String? fitnessLevel;
  final List<WorkoutGoal>? goals;
  final List<String>? injuries;
  final List<String>? achievements;

  UserPreferences({
    this.workoutTime,
    this.workoutDuration,
    this.equipment,
    this.goal,
    this.experienceLevel,
    this.healthIssues,
    this.workoutDays,
    this.preferredDuration,
    this.fitnessLevel,
    this.goals,
    this.injuries,
    this.achievements,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      workoutTime: map['workout_time'],
      workoutDuration: map['workout_duration'],
      equipment:
          map['equipment'] != null ? List<String>.from(map['equipment']) : null,
      goal: map['goal'] != null ? _parseWorkoutGoal(map['goal']) : null,
      experienceLevel: map['experience_level'] != null
          ? _parseExperienceLevel(map['experience_level'])
          : null,
      healthIssues: map['health_issues'],
      workoutDays: map['workout_days'] != null
          ? List<String>.from(map['workout_days'])
          : null,
      preferredDuration: map['preferred_duration'],
      fitnessLevel: map['fitness_level'],
      goals: (map['goals'] as List?)
          ?.map((g) => _parseWorkoutGoal(g.toString()))
          .toList(),
      injuries:
          map['injuries'] != null ? List<String>.from(map['injuries']) : null,
      achievements: map['achievements'] != null
          ? List<String>.from(map['achievements'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workout_time': workoutTime,
      'workout_duration': workoutDuration,
      'equipment': equipment,
      'goal': goal?.name,
      'experience_level': experienceLevel?.name,
      'health_issues': healthIssues,
      'workout_days': workoutDays,
      'preferred_duration': preferredDuration,
      'fitness_level': fitnessLevel,
      'goals': goals?.map((g) => g.name).toList(),
      'injuries': injuries,
      'achievements': achievements,
    };
  }

  UserPreferences copyWith({
    String? workoutTime,
    String? workoutDuration,
    List<String>? equipment,
    WorkoutGoal? goal,
    ExperienceLevel? experienceLevel,
    String? healthIssues,
    List<String>? workoutDays,
    int? preferredDuration,
    String? fitnessLevel,
    List<WorkoutGoal>? goals,
    List<String>? injuries,
    List<String>? achievements,
  }) {
    return UserPreferences(
      workoutTime: workoutTime ?? this.workoutTime,
      workoutDuration: workoutDuration ?? this.workoutDuration,
      equipment: equipment ?? this.equipment,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      healthIssues: healthIssues ?? this.healthIssues,
      workoutDays: workoutDays ?? this.workoutDays,
      preferredDuration: preferredDuration ?? this.preferredDuration,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goals: goals ?? this.goals,
      injuries: injuries ?? this.injuries,
      achievements: achievements ?? this.achievements,
    );
  }

  static WorkoutGoal _parseWorkoutGoal(String value) {
    switch (value.toLowerCase()) {
      case 'weight_loss':
      case 'ירידה במשקל':
        return WorkoutGoal.weightLoss;
      case 'muscle_gain':
      case 'עלייה במסת שריר':
      case 'עלייה במסה':
        return WorkoutGoal.muscleGain;
      case 'endurance':
      case 'סיבולת':
      case 'שיפור סיבולת/כושר כללי':
      case 'שיפור כושר גופני כללי':
        return WorkoutGoal.endurance;
      case 'strength':
      case 'כוח':
        return WorkoutGoal.strength;
      case 'flexibility':
      case 'גמישות':
        return WorkoutGoal.flexibility;
      case 'חיטוב ועיצוב':
      case 'חיטוב ועיצוב הגוף':
      case 'שיפור בריאות וחיוניות':
      default:
        return WorkoutGoal.generalFitness;
    }
  }

  static ExperienceLevel _parseExperienceLevel(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
      case 'מתחיל':
      case 'מתחיל מוחלט':
      case 'מתחיל עם ניסיון בסיסי':
        return ExperienceLevel.beginner;
      case 'intermediate':
      case 'בינוני':
      case 'מתאמן בינוני':
        return ExperienceLevel.intermediate;
      case 'advanced':
      case 'מתקדם':
        return ExperienceLevel.advanced;
      case 'expert':
      case 'מומחה':
      case 'מנוסה מאוד':
        return ExperienceLevel.expert;
      default:
        return ExperienceLevel.beginner;
    }
  }
}

class WorkoutHistory {
  final String workoutId;
  final DateTime date;
  final int rating;
  final String? feedback;
  final List<ExerciseHistory>? exerciseHistory;

  WorkoutHistory({
    required this.workoutId,
    required this.date,
    required this.rating,
    this.feedback,
    this.exerciseHistory,
  });

  factory WorkoutHistory.fromMap(Map<String, dynamic> map) {
    final workoutId =
        map['workout_id'] ?? 'wrk_${DateTime.now().millisecondsSinceEpoch}';
    final date = map['date'] != null
        ? DateTime.parse(map['date'].toString())
        : DateTime.now();
    final rating = map['rating'] ?? 0;
    final feedback = map['feedback'];
    final rawExerciseHistory = map['exercise_history'];
    List<ExerciseHistory> exerciseHistoryList = [];
    if (rawExerciseHistory != null && rawExerciseHistory is List) {
      exerciseHistoryList = rawExerciseHistory
          .map((e) {
            if (e is ExerciseHistory) return e;
            if (e is Map<String, dynamic>) return ExerciseHistory.fromMap(e);
            if (e is String) {
              try {
                return ExerciseHistory.fromMap(json.decode(e));
              } catch (_) {
                return null;
              }
            }
            return null;
          })
          .whereType<ExerciseHistory>()
          .toList();
    }
    return WorkoutHistory(
      workoutId: workoutId,
      date: date,
      rating: rating,
      feedback: feedback,
      exerciseHistory: exerciseHistoryList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workout_id': workoutId,
      'date': date.toIso8601String(),
      'rating': rating,
      'feedback': feedback,
      'exercise_history': exerciseHistory?.map((e) => e.toMap()).toList(),
    };
  }
}
