// lib/screens/auth/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../screens/register_screen.dart';
import '../../theme/app_theme.dart';
import '../../screens/home_screen.dart';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  String? _emailError;
  String? _passwordError;
  bool _isPasswordVisible = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  String? _socialAuthError;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  static final List<String> demoEmails =
      List.generate(10, (i) => 'demo${i + 1}@gymovo.com');
  static const String demoPassword = 'demoUser123';

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _validateEmail();
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
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
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _emailError = null;
        _passwordError = null;
      });

      // סגירת המקלדת
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // קריאה ל־register במקום login כי אין לנו login רגיל
      await authProvider.register(
        email: email,
        password: password,
        name: email.split('@')[0], // שימוש בשם משתמש מהאימייל
      );

      if (authProvider.isLoggedIn && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (authProvider.error != null && mounted) {
        setState(() {
          if (authProvider.error!.contains('אימייל')) {
            _emailError = authProvider.error;
          } else if (authProvider.error!.contains('סיסמה')) {
            _passwordError = authProvider.error;
          } else {
            _emailError = authProvider.error;
          }
        });
      }
    }
  }

  Future<void> _loginAsDemoUser() async {
    // סגירת המקלדת
    FocusScope.of(context).unfocus();

    final random = Random();
    final demoEmail = _emailController.text.isNotEmpty &&
            demoEmails.contains(_emailController.text)
        ? _emailController.text
        : demoEmails[random.nextInt(demoEmails.length)];

    final authProvider = context.read<AuthProvider>();
    await authProvider.loginAsDemoUser();

    if (authProvider.isLoggedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (authProvider.error != null && mounted) {
      setState(() {
        _emailError = authProvider.error;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _socialAuthError = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    final success = DateTime.now().millisecondsSinceEpoch % 5 != 0;

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'התחברת בהצלחה עם Google!',
              style: GoogleFonts.assistant(),
            ),
            backgroundColor: AppTheme.colors.primary,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } else {
      setState(() {
        _socialAuthError = 'ההתחברות עם Google נכשלה. אנא נסה שוב.';
      });
    }

    if (mounted) {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isFacebookLoading = true;
      _socialAuthError = null;
    });

    await Future.delayed(const Duration(seconds: 2));
    final success = DateTime.now().millisecondsSinceEpoch % 5 != 0;

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'התחברת בהצלחה עם Facebook!',
              style: GoogleFonts.assistant(),
            ),
            backgroundColor: AppTheme.colors.primary,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } else {
      setState(() {
        _socialAuthError = 'ההתחברות עם Facebook נכשלה. אנא נסה שוב.';
      });
    }

    if (mounted) {
      setState(() {
        _isFacebookLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final colors = AppTheme.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // לוגו מעוצב עם אפקטים
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
                        height: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withAlpha((0.85 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                colors.primary.withAlpha((0.3 * 255).round()),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // שדה אימייל
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    style: GoogleFonts.assistant(),
                                    decoration: InputDecoration(
                                      labelText: 'אימייל',
                                      labelStyle: GoogleFonts.assistant(),
                                      prefixIcon: Icon(Icons.email,
                                          color: colors.secondary),
                                      errorText: _emailError,
                                      errorStyle: GoogleFonts.assistant(
                                        color: colors.error,
                                      ),
                                      helperText:
                                          'יש להקליד כתובת תקינה (רק באנגלית)',
                                      helperStyle: GoogleFonts.assistant(
                                        fontSize: 12,
                                        color: colors.text.withOpacity(0.6),
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    textDirection: TextDirection.ltr,
                                    onChanged: (value) {
                                      setState(() => _emailError = null);
                                    },
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
                                    focusNode: _passwordFocusNode,
                                    style: GoogleFonts.assistant(),
                                    decoration: InputDecoration(
                                      labelText: 'סיסמה',
                                      labelStyle: GoogleFonts.assistant(),
                                      prefixIcon: Icon(Icons.lock,
                                          color: colors.secondary),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: colors.secondary,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      errorText: _passwordError,
                                      errorStyle: GoogleFonts.assistant(
                                        color: colors.error,
                                      ),
                                    ),
                                    obscureText: !_isPasswordVisible,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _login(),
                                    onChanged: (value) {
                                      setState(() => _passwordError = null);
                                    },
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
                                  if (authProvider.error != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: colors.error.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: colors.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              authProvider.error!,
                                              style: GoogleFonts.assistant(
                                                color: colors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 32),
                                  // כפתור התחברות
                                  ElevatedButton(
                                    onPressed:
                                        authProvider.isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.text,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: authProvider.isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                colors.accent,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'התחבר',
                                            style: GoogleFonts.assistant(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 24),
                                  // כפתורי התחברות מהירה
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _isGoogleLoading
                                              ? null
                                              : _handleGoogleSignIn,
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            side: BorderSide(
                                                color: colors.secondary),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: _isGoogleLoading
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      colors.accent,
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/icons/google_logo.png',
                                                  height: 24,
                                                  width: 24,
                                                  fit: BoxFit.contain,
                                                ),
                                          label: Text(
                                            'Google',
                                            style: GoogleFonts.assistant(
                                              color: colors.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _isFacebookLoading
                                              ? null
                                              : _handleFacebookSignIn,
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            side: BorderSide(
                                                color: colors.secondary),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: _isFacebookLoading
                                              ? SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      colors.accent,
                                                    ),
                                                  ),
                                                )
                                              : Image.asset(
                                                  'assets/icons/facebook_logo.png',
                                                  height: 24,
                                                  width: 24,
                                                  fit: BoxFit.contain,
                                                ),
                                          label: Text(
                                            'Facebook',
                                            style: GoogleFonts.assistant(
                                              color: colors.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_socialAuthError != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: colors.error.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: colors.error,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _socialAuthError!,
                                              style: GoogleFonts.assistant(
                                                color: colors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 24),
                                  // כפתור משתמש דמו
                                  OutlinedButton.icon(
                                    onPressed: _loginAsDemoUser,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      side: BorderSide(color: colors.secondary),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.person_outline,
                                      color: colors.secondary,
                                    ),
                                    label: Text(
                                      'התחבר כמשתמש דמו',
                                      style: GoogleFonts.assistant(
                                        color: colors.text,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // קישור להרשמה
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'אין לך חשבון? הירשם כאן',
                                      style: GoogleFonts.assistant(
                                        color: colors.secondary,
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
