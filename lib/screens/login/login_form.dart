// lib/screens/login/login_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class LoginForm extends StatefulWidget {
  final String? prefilledEmail;

  const LoginForm({super.key, this.prefilledEmail});

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // אם יש אימייל מוכן מראש, הכנס אותו
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
      // הכנס גם סיסמה ברירת מחדל למשתמשי דמו
      _passwordController.text = 'demo123';
    }
  }

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

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      // בדיקה אם זה משתמש דמו
      if (_emailController.text.contains('@example.com') ||
          _emailController.text.contains('@gymovo.com') ||
          _passwordController.text == 'demo123') {
        // התחברות כמשתמש דמו
        await authProvider.loginAsDemoUser();
      } else {
        // כאן תוכל להוסיף לוגיקה להתחברות רגילה
        // כרגע נשתמש בדמו גם כן
        await authProvider.loginAsDemoUser();
      }

      if (mounted) {
        if (authProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // ניווט למסך הבית
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בהתחברות: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          // כפתור התחברות
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'התחבר',
                    style: GoogleFonts.assistant(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
