// --------------------------------------------------
// עזרים לאימות משופרים
// --------------------------------------------------
class LoginValidation {
  // ביטוי רגולרי משופר לאימייל
  static final _emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");

  // ביטויים רגולריים לאימות סיסמה חזקה
  static final _uppercaseRegExp = RegExp(r'[A-Z]');
  static final _lowercaseRegExp = RegExp(r'[a-z]');
  static final _numberRegExp = RegExp(r'[0-9]');
  static final _specialCharRegExp =
      RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]');

  static bool isValidEmail(String email) {
    return _emailRegExp.hasMatch(email.trim());
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'נא להזין אימייל';
    }

    final trimmedValue = value.trim();

    if (!isValidEmail(trimmedValue)) {
      return 'נא להזין אימייל תקין (למשל: name@email.com)';
    }

    // בדיקת אורך מקסימלי
    if (trimmedValue.length > 254) {
      return 'האימייל ארוך מדי';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'נא להזין סיסמה';
    }

    if (value.length < 6) {
      return 'הסיסמה חייבת להכיל לפחות 6 תווים';
    }

    if (value.length > 128) {
      return 'הסיסמה ארוכה מדי (מקסימום 128 תווים)';
    }

    return null;
  }

  // אימות סיסמה חזקה (אופציונלי)
  static String? validateStrongPassword(String? value) {
    final basicValidation = validatePassword(value);
    if (basicValidation != null) return basicValidation;

    if (value == null) return null;

    // רשימת דרישות שחסרות
    List<String> missingRequirements = [];

    if (!_uppercaseRegExp.hasMatch(value)) {
      missingRequirements.add('אות גדולה');
    }

    if (!_lowercaseRegExp.hasMatch(value)) {
      missingRequirements.add('אות קטנה');
    }

    if (!_numberRegExp.hasMatch(value)) {
      missingRequirements.add('ספרה');
    }

    if (!_specialCharRegExp.hasMatch(value)) {
      missingRequirements.add('תו מיוחד (!@#\$%^&* וכו\')');
    }

    // אם יש דרישות שחסרות, החזר הודעה מפורטת
    if (missingRequirements.isNotEmpty) {
      if (missingRequirements.length == 1) {
        return 'הסיסמה חייבת להכיל לפחות ${missingRequirements.first}';
      } else {
        return 'הסיסמה חייבת להכיל: ${missingRequirements.join(', ')}';
      }
    }

    return null;
  }

  // בדיקת עוצמת סיסמה (מחזירה ציון 0-4)
  static int getPasswordStrength(String? password) {
    if (password == null || password.isEmpty) return 0;

    int strength = 0;

    if (password.length >= 6) strength++;
    if (password.length >= 12) strength++;
    if (_uppercaseRegExp.hasMatch(password) &&
        _lowercaseRegExp.hasMatch(password)) strength++;
    if (_numberRegExp.hasMatch(password)) strength++;
    if (_specialCharRegExp.hasMatch(password)) strength++;

    return strength > 4 ? 4 : strength;
  }

  // תיאור עוצמת הסיסמה
  static String getPasswordStrengthDescription(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'חלשה מאוד';
      case 2:
        return 'חלשה';
      case 3:
        return 'בינונית';
      case 4:
        return 'חזקה';
      default:
        return 'לא ידוע';
    }
  }

  // אימות התאמת סיסמאות
  static String? validatePasswordConfirmation(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'נא לאמת את הסיסמה';
    }

    if (password != confirmPassword) {
      return 'הסיסמאות אינן תואמות';
    }

    return null;
  }

  // בדיקה כללית לטופס התחברות
  static Map<String, String?> validateLoginForm({
    required String? email,
    required String? password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
    };
  }

  // אימות שם משתמש
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'נא להזין שם';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'השם חייב להכיל לפחות 2 תווים';
    }

    if (trimmedValue.length > 50) {
      return 'השם ארוך מדי (מקסימום 50 תווים)';
    }

    // בדיקה שהשם מכיל רק אותיות ורווחים
    if (!RegExp(r'^[a-zA-Zא-ת\s]+$').hasMatch(trimmedValue)) {
      return 'השם יכול להכיל רק אותיות ורווחים';
    }

    return null;
  }

  // אימות מספר טלפון ישראלי
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'נא להזין מספר טלפון';
    }

    // הסרת רווחים ומקפים
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-]'), '');

    // בדיקת פורמטים ישראליים נפוצים
    final israeliPhoneRegex =
        RegExp(r'^(\+972|972|0)?([5][0-9]|[2-4][0-9]|[8-9][0-9])[0-9]{7}$');

    if (!israeliPhoneRegex.hasMatch(cleanedValue)) {
      return 'נא להזין מספר טלפון תקין (למשל: 050-1234567)';
    }

    return null;
  }

  // בדיקה כללית לטופס הרשמה
  static Map<String, String?> validateRegistrationForm({
    required String? email,
    required String? password,
    required String? confirmPassword,
    bool requireStrongPassword = false,
    String? name,
    String? phoneNumber,
  }) {
    Map<String, String?> results = {
      'email': validateEmail(email),
      'password': requireStrongPassword
          ? validateStrongPassword(password)
          : validatePassword(password),
      'confirmPassword':
          validatePasswordConfirmation(password, confirmPassword),
    };

    // אימות שם (אם נדרש)
    if (name != null) {
      results['name'] = validateName(name);
    }

    // אימות מספר טלפון (אם נדרש)
    if (phoneNumber != null) {
      results['phoneNumber'] = validatePhoneNumber(phoneNumber);
    }

    return results;
  }

  // עזר לבדיקה האם הטופס תקין
  static bool isFormValid(Map<String, String?> validationResults) {
    return validationResults.values.every((error) => error == null);
  }
}
