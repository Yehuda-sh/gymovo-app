// lib/screens/questionnaire/managers/questionnaire_validation_manager.dart

import '../../../models/question_model.dart';
import '../../../questionnaire/questions.dart' as q;

class QuestionnaireValidationManager {
  static Map<String, String> validateAnswers(Map<String, dynamic> answers) {
    final errors = <String, String>{};

    for (final question in q.allQuestions) {
      if (!question.showIf(answers)) continue;

      final error = validateAnswer(question, answers[question.id]);
      if (error != null) {
        errors[question.id] = error;
      }
    }

    return errors;
  }

  static String? validateAnswer(q.Question question, dynamic answer) {
    // בדיקה בסיסית - תשובה חובה
    if (answer == null ||
        (answer is List && answer.isEmpty) ||
        (answer is String && answer.trim().isEmpty)) {
      return 'שדה חובה';
    }

    // ולידציה לפי סוג השאלה
    if (question.inputType == 'number') {
      return _validateNumber(answer);
    } else if (question.multi) {
      return _validateMultipleChoice(answer, question.maxSelections);
    }

    return null;
  }

  static String? _validateNumber(dynamic answer) {
    if (answer == null) return null;

    final num? value = answer is num ? answer : num.tryParse(answer.toString());
    if (value == null) return 'ערך לא תקין';

    return null;
  }

  static String? _validateMultipleChoice(dynamic answer, int? maxSelections) {
    if (answer is! List) return null;

    final list = answer as List;

    if (maxSelections != null && list.length > maxSelections) {
      return 'ניתן לבחור עד $maxSelections אפשרויות';
    }

    return null;
  }

  // דוגמאות לוולידציות ייעודיות
  static String? validateAge(dynamic age) {
    if (age == null) return 'גיל חובה';

    final ageNum = age is num ? age : num.tryParse(age.toString());
    if (ageNum == null) return 'גיל לא תקין';

    if (ageNum < 16) return 'גיל מינימלי: 16';
    if (ageNum > 90) return 'גיל מקסימלי: 90';

    return null;
  }

  static String? validateWeight(dynamic weight) {
    if (weight == null) return 'משקל חובה';

    final weightNum = weight is num ? weight : num.tryParse(weight.toString());
    if (weightNum == null) return 'משקל לא תקין';

    if (weightNum < 30) return 'משקל מינימלי: 30 ק"ג';
    if (weightNum > 200) return 'משקל מקסימלי: 200 ק"ג';

    return null;
  }

  static String? validateHeight(dynamic height) {
    if (height == null) return 'גובה חובה';

    final heightNum = height is num ? height : num.tryParse(height.toString());
    if (heightNum == null) return 'גובה לא תקין';

    if (heightNum < 140) return 'גובה מינימלי: 140 ס"מ';
    if (heightNum > 210) return 'גובה מקסימלי: 210 ס"מ';

    return null;
  }
}
