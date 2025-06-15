// lib/screens/register/register_screen.dart
// --------------------------------------------------
// מסך הרשמה ראשי לאפליקציה
// --------------------------------------------------

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login/login_screen.dart';
import '../../data/local_data_store.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEnglishName(String name) =>
      RegExp(r"^[A-Za-z\s]+$").hasMatch(name);

  bool _isValidPassword(String password) {
    return password.length >= 6 &&
        password.length <= 12 &&
        RegExp(r"^[A-Za-z0-9]+$").hasMatch(password) &&
        RegExp(r"[A-Za-z]").hasMatch(password) &&
        RegExp(r"[0-9]").hasMatch(password);
  }

  Future<void> _register() async {
    setState(() => _errorText = null);

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await context.read<AuthProvider>().register(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
            );

        final authProvider = context.read<AuthProvider>();
        if (authProvider.isLoggedIn && mounted) {
          // מיגרציה של נתוני אורח אם קיימים
          final user = authProvider.currentUser;
          if (user != null) {
            await LocalDataStore.migrateGuestDataToUser(user.id);
            await LocalDataStore.saveCurrentUser(user);
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (authProvider.error != null && mounted) {
          setState(() => _errorText = authProvider.error);
        }
      } catch (e) {
        if (mounted) setState(() => _errorText = e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _socialRegisterNotImplemented(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('הרשמה עם $provider אינה זמינה כרגע')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/gymovo_logo.png',
                        height: 130,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon:
                            Image.asset('assets/icons/google.png', height: 36),
                        onPressed: () =>
                            _socialRegisterNotImplemented('Google'),
                        tooltip: 'הרשמה עם Google',
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Image.asset('assets/icons/facebook.png',
                            height: 36),
                        onPressed: () =>
                            _socialRegisterNotImplemented('Facebook'),
                        tooltip: 'הרשמה עם Facebook',
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Image.asset('assets/icons/apple.png', height: 36),
                        onPressed: () => _socialRegisterNotImplemented('Apple'),
                        tooltip: 'הרשמה עם Apple',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 450),
                      decoration: BoxDecoration(
                        color: colors.surface.withOpacity(0.87),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    style: GoogleFonts.assistant(),
                                    decoration: InputDecoration(
                                      labelText: 'שם מלא',
                                      labelStyle: GoogleFonts.assistant(),
                                      hintText: "לדוג' Michael Levi",
                                      helperText:
                                          'השם יופיע בפרופיל שלך ויהיה גלוי למשתמשים אחרים',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'נא להזין שם';
                                      }
                                      if (!_isValidEnglishName(value)) {
                                        return 'נא להזין שם באנגלית בלבד';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    style: GoogleFonts.assistant(),
                                    decoration: InputDecoration(
                                      labelText: 'אימייל',
                                      labelStyle: GoogleFonts.assistant(),
                                      hintText: 'your.email@example.com',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'נא להזין אימייל';
                                      }
                                      if (!value.contains('@') ||
                                          !value.contains('.')) {
                                        return 'נא להזין אימייל תקין';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    style: GoogleFonts.assistant(),
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'סיסמה',
                                      labelStyle: GoogleFonts.assistant(),
                                      helperText:
                                          '6-12 תווים, אותיות באנגלית ומספרים',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'נא להזין סיסמה';
                                      }
                                      if (!_isValidPassword(value)) {
                                        return 'הסיסמה חייבת להכיל 6-12 תווים, אותיות באנגלית ומספרים';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (_errorText != null) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      _errorText!,
                                      style: GoogleFonts.assistant(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.text,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            'הרשמה',
                                            style: GoogleFonts.assistant(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'כבר יש לך חשבון? התחבר',
                                      style: GoogleFonts.assistant(
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
