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
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController(text: widget.prefilledEmail ?? '');
    _passwordController = TextEditingController(
        text: widget.prefilledEmail != null ? 'demo123' : '');

    // נקה שגיאות בשינוי טקסט
    _emailController.addListener(() {
      if (_emailError != null) setState(() => _emailError = null);
    });
    _passwordController.addListener(() {
      if (_passwordError != null) setState(() => _passwordError = null);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return regex.hasMatch(email);
  }

  void _validateEmail() {
    final value = _emailController.text.trim();
    if (value.isEmpty) {
      setState(() => _emailError = 'נא להזין אימייל');
    } else if (!_isValidEmail(value)) {
      setState(
          () => _emailError = 'נא להזין אימייל תקין (למשל: name@email.com)');
    } else {
      setState(() => _emailError = null);
    }
  }

  void _validatePassword() {
    final value = _passwordController.text;
    if (value.isEmpty) {
      setState(() => _passwordError = 'נא להזין סיסמה');
    } else if (value.length < 6) {
      setState(() => _passwordError = 'הסיסמה חייבת להכיל לפחות 6 תווים');
    } else {
      setState(() => _passwordError = null);
    }
  }

  Future<void> _login() async {
    _validateEmail();
    _validatePassword();

    if (_emailError != null || _passwordError != null) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final isDemoUser = email.contains('@example.com') ||
          email.contains('@gymovo.com') ||
          password == 'demo123';

      if (isDemoUser) {
        await authProvider.loginAsDemoUser();
      } else {
        // כאן תוכל להוסיף התחברות אמיתית בעתיד
        await authProvider.loginAsDemoUser();
      }

      if (!mounted) return;

      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4facfe),
            Color(0xFF00f2fe),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4facfe).withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // כותרת
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.login,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'התחברות',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // שדה אימייל
                _buildEmailField(colors),

                const SizedBox(height: 20),

                // שדה סיסמה
                _buildPasswordField(colors),

                const SizedBox(height: 32),

                // כפתור התחברות
                _buildLoginButton(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        style: GoogleFonts.assistant(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'אימייל',
          labelStyle: GoogleFonts.assistant(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.8)),
          errorText: _emailError,
          errorStyle:
              GoogleFonts.assistant(color: Colors.red[200], fontSize: 12),
          helperText: 'יש להקליד כתובת תקינה (רק באנגלית)',
          helperStyle: GoogleFonts.assistant(
              fontSize: 12, color: Colors.white.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        textDirection: TextDirection.ltr,
        onFieldSubmitted: (_) {
          _validateEmail();
          FocusScope.of(context).nextFocus();
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'אנא הכנס אימייל';
          }
          if (!_isValidEmail(value)) {
            return 'נא להזין אימייל תקין (למשל: name@email.com)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        style: GoogleFonts.assistant(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'סיסמה',
          labelStyle: GoogleFonts.assistant(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.lock, color: Colors.white.withOpacity(0.8)),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.8),
            ),
            onPressed: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
          errorText: _passwordError,
          errorStyle:
              GoogleFonts.assistant(color: Colors.red[200], fontSize: 12),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        obscureText: !_isPasswordVisible,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _validatePassword(),
        textDirection: TextDirection.ltr,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'אנא הכנס סיסמה';
          }
          if (value.length < 6) {
            return 'הסיסמה חייבת להכיל לפחות 6 תווים';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFf8f9fa),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _isLoading ? null : _login,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF4facfe)),
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4facfe),
                          Color(0xFF00f2fe),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.login,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  _isLoading ? 'מתחבר...' : 'התחבר',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isLoading
                        ? const Color(0xFF4facfe)
                        : const Color(0xFF2d3748),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
