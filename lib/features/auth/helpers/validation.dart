// --------------------------------------------------
// עזרים לאימות
// --------------------------------------------------
class LoginValidation {
  static bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'נא להזין אימייל';
    }
    if (!isValidEmail(value)) {
      return 'נא להזין אימייל תקין (למשל: name@email.com)';
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
    return null;
  }
}
