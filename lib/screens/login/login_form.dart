// lib/screens/login/login_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email);
  }

  void _validateEmail() {
    final value = _emailController.text;
    String? error;
    if (value.isEmpty) {
      error = 'נא להזין אימייל';
    } else if (!isValidEmail(value)) {
      error = 'נא להזין אימייל תקין (למשל: name@email.com)';
    }
    setState(() {
      _emailError = error;
    });
  }

  void _validatePassword() {
    final value = _passwordController.text;
    String? error;
    if (value.isEmpty) {
      error = 'נא להזין סיסמה';
    } else if (value.length < 6) {
      error = 'הסיסמה חייבת להכיל לפחות 6 תווים';
    }
    setState(() {
      _passwordError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // שדה אימייל
          TextFormField(
            controller: _emailController,
            style: GoogleFonts.assistant(),
            decoration: InputDecoration(
              labelText: 'אימייל',
              labelStyle: GoogleFonts.assistant(),
              prefixIcon: Icon(Icons.email, color: colors.secondary),
              errorText: _emailError,
              errorStyle: GoogleFonts.assistant(color: colors.error),
              helperText: 'יש להקליד כתובת תקינה (רק באנגלית)',
              helperStyle: GoogleFonts.assistant(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            textDirection: TextDirection.ltr,
            onChanged: (value) => setState(() => _emailError = null),
            onFieldSubmitted: (_) {
              _validateEmail();
              FocusScope.of(context).nextFocus();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'אנא הכנס אימייל';
              }
              if (!isValidEmail(value)) {
                return 'נא להזין אימייל תקין (למשל: name@email.com)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // שדה סיסמה
          TextFormField(
            controller: _passwordController,
            style: GoogleFonts.assistant(),
            decoration: InputDecoration(
              labelText: 'סיסמה',
              labelStyle: GoogleFonts.assistant(),
              prefixIcon: Icon(Icons.lock, color: colors.secondary),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: colors.secondary,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              errorText: _passwordError,
              errorStyle: GoogleFonts.assistant(color: colors.error),
            ),
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _validatePassword(),
            onChanged: (value) => setState(() => _passwordError = null),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'אנא הכנס סיסמה';
              }
              if (value.length < 6) {
                return 'הסיסמה חייבת להכיל לפחות 6 תווים';
              }
              return null;
            },
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(height: 32),
          // כפתור התחברות (כדוגמה בלבד)
          ElevatedButton(
            onPressed: () {
              _validateEmail();
              _validatePassword();
              if (_formKey.currentState?.validate() ?? false) {
                // כאן תכניס את הלוגיקה שלך
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('מתחבר...')),
                );
              }
            },
            child: const Text('התחבר'),
          ),
        ],
      ),
    );
  }
}
