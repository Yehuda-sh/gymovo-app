// lib/screens/questionnaire/services/questionnaire_analytics.dart

class QuestionnaireAnalytics {
  static Map<String, dynamic> analyzeAnswers(Map<String, dynamic> answers) {
    final analysis = <String, dynamic>{};

    // חישוב BMI
    if (answers['height'] != null && answers['weight'] != null) {
      analysis['bmi'] = _calculateBMI(answers['height'], answers['weight']);
      analysis['bmi_category'] = _getBMICategory(analysis['bmi']);
    }

    // רמת כושר מוערכת
    analysis['fitness_level'] = _calculateFitnessLevel(answers);

    // המלצות אימון
    analysis['training_recommendations'] = _getTrainingRecommendations(answers);

    // זמן אימון שבועי מוער
    analysis['weekly_training_time'] = _calculateWeeklyTrainingTime(answers);

    // רמת מוטיבציה
    analysis['motivation_level'] = _calculateMotivationLevel(answers);

    return analysis;
  }

  static double _calculateBMI(dynamic height, dynamic weight) {
    final h = double.parse(height.toString()) / 100; // Convert to meters
    final w = double.parse(weight.toString());
    return w / (h * h);
  }

  static String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'תת משקל';
    if (bmi < 25) return 'משקל תקין';
    if (bmi < 30) return 'עודף משקל';
    return 'השמנה';
  }

  static String _calculateFitnessLevel(Map<String, dynamic> answers) {
    int score = 0;

    // ניקוד לפי התאמנות אחרונה
    switch (answers['exercise_break']) {
      case 'כן, באופן קבוע (3+ פעמים בשבוע)':
        score += 4;
        break;
      case 'כן, לסירוגין (1-2 פעמים בשבוע)':
        score += 2;
        break;
      case 'לא, הייתה לי הפסקה':
        score += 1;
        break;
      default:
        score += 0;
    }

    // ניקוד לפי רמת ניסיון
    switch (answers['experience_level']) {
      case 'מנוסה מאוד':
        score += 4;
        break;
      case 'מתקדם':
        score += 3;
        break;
      case 'מתאמן בינוני':
        score += 2;
        break;
      case 'מתחיל עם ניסיון בסיסי':
        score += 1;
        break;
      default:
        score += 0;
    }

    // ניקוד לפי תדירות מתוכננת
    switch (answers['frequency']) {
      case 'כל יום':
        score += 4;
        break;
      case '5-6 פעמים':
        score += 3;
        break;
      case '3-4 פעמים':
        score += 2;
        break;
      default:
        score += 1;
    }

    if (score >= 10) return 'גבוהה מאוד';
    if (score >= 8) return 'גבוהה';
    if (score >= 5) return 'בינונית';
    if (score >= 3) return 'נמוכה';
    return 'מתחיל';
  }

  static List<String> _getTrainingRecommendations(
      Map<String, dynamic> answers) {
    final recommendations = <String>[];

    final goal = answers['goal'];
    final experienceLevel = answers['experience_level'];
    final healthLimitations = answers['health_limitations'] as List?;

    // המלצות לפי מטרה
    switch (goal) {
      case 'ירידה במשקל':
        recommendations.add('שילוב אימוני כוח ואירובי');
        recommendations.add('דגש על HIIT ואינטרוולים');
        recommendations.add('מעקב תזונתי קפדני');
        break;
      case 'עלייה במסת שריר':
        recommendations.add('אימוני כוח פרוגרסיביים');
        recommendations.add('דגש על תרגילים מורכבים');
        recommendations.add('צריכת חלבון גבוהה');
        break;
      case 'חיטוב ועיצוב הגוף':
        recommendations.add('שילוב כוח וסיבולת');
        recommendations.add('תרגילי ליבה מתקדמים');
        recommendations.add('תזונה מותאמת להרזיה מבוקרת');
        break;
      case 'שיפור כושר גופני כללי':
        recommendations.add('תוכנית מגוונת ומאוזנת');
        recommendations.add('דגש על תנועות פונקציונליות');
        recommendations.add('שיפור סיבולת קרדיו-וסקולרית');
        break;
    }

    return recommendations;
  }

  static int _calculateWeeklyTrainingTime(Map<String, dynamic> answers) {
    // Example logic: adjust as needed for your questionnaire fields
    // Assumes 'frequency' is times per week, 'workout_duration' is a string like '30-45 דקות'
    int sessions = 0;
    int minutesPerSession = 0;

    switch (answers['frequency']) {
      case 'כל יום':
        sessions = 7;
        break;
      case '5-6 פעמים':
        sessions = 6;
        break;
      case '3-4 פעמים':
        sessions = 4;
        break;
      case '1-2 פעמים':
        sessions = 2;
        break;
      default:
        sessions = 3;
    }

    final duration = answers['workout_duration'] ?? '';
    if (duration.contains('עד 30')) {
      minutesPerSession = 30;
    } else if (duration.contains('30-45')) {
      minutesPerSession = 40;
    } else if (duration.contains('45-60')) {
      minutesPerSession = 55;
    } else if (duration.contains('מעל שעה')) {
      minutesPerSession = 70;
    } else {
      minutesPerSession = 40;
    }

    return sessions * minutesPerSession;
  }

  static String _calculateMotivationLevel(Map<String, dynamic> answers) {
    // Implementation of motivation level calculation
    // This is a placeholder and should be replaced with actual logic
    return 'מושלם';
  }

  static Map<String, String> generatePersonalizedTips(
      Map<String, dynamic> answers) {
    final tips = <String, String>{};

    // טיפים לפי BMI
    final analysis = analyzeAnswers(answers);
    if (analysis['bmi_category'] != null) {
      switch (analysis['bmi_category']) {
        case 'תת משקל':
          tips['nutrition'] = 'התמקד בעלייה במסת שריר עם צריכת קלוריות עודפת';
          break;
        case 'עודף משקל':
        case 'השמנה':
          tips['nutrition'] = 'שילוב דיאטה מותאמת עם אימוני אירובי';
          break;
        default:
          tips['nutrition'] = 'שמור על תזונה מאוזנת לתמיכה ביעדי הכושר';
      }
    }

    // טיפים לפי גיל
    final age = answers['age'];
    if (age != null) {
      final ageNum = int.tryParse(age.toString());
      if (ageNum != null) {
        if (ageNum < 25) {
          tips['recovery'] = 'גופך מתאושש מהר - נצל זאת לאימונים אינטנסיביים';
        } else if (ageNum > 40) {
          tips['recovery'] = 'התמקד בהתאוששות איכותית ומניעת פציעות';
        }
      }
    }

    // טיפים לפי ניסיון
    switch (answers['experience_level']) {
      case 'מתחיל מוחלט':
        tips['technique'] =
            'השקע זמן בלימוד טכניקה נכונה - זה ייחסוך פציעות בעתיד';
        break;
      case 'מתקדם':
      case 'מנוסה מאוד':
        tips['progression'] = 'נסה טכניקות התקדמות מתקדמות כמו פריודיזציה';
        break;
    }

    return tips;
  }
}
