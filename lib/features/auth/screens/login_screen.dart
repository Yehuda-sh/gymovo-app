// features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/social_login_button.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/home/home_screen.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

// דוגמה זו מניחה שכל הרכיבים קיימים בתיקיית widgets, והייבוא הוא מוחלט (absolute)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static final List<String> demoEmails =
      List.generate(10, (i) => 'demo${i + 1}@gymovo.com');
  static const String demoPassword = 'demoUser123';
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // --- State, controllers, focus nodes ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  String? _emailError;
  String? _passwordError;
  String? _generalError;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  // --- אנימציות ל־Header ---
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeInOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic)),
    );
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

  // --- Callbacks ---

  void _onLogin() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    // דוגמה בלבד – תחליף עם authProvider.login(...)
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      // אפשר לעדכן הודעת שגיאה בהתאם לתוצאה
      // _generalError = "שגיאה לדוגמה";
    });
  }

  void _onForgotPassword() {
    // טיפול בשכחת סיסמה
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('פיצ\'ר שכחת סיסמה טרם מומש')),
    );
  }

  void _onGoogleLogin() async {
    setState(() {
      _isGoogleLoading = true;
      _generalError = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isGoogleLoading = false;
    });
  }

  void _onFacebookLogin() async {
    setState(() {
      _isFacebookLoading = true;
      _generalError = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isFacebookLoading = false;
    });
  }

  Future<void> _loginAsDemoUser() async {
    // סגירת המקלדת
    FocusScope.of(context).unfocus();

    final random = Random();
    final demoEmail = _emailController.text.isNotEmpty &&
            LoginScreen.demoEmails.contains(_emailController.text)
        ? _emailController.text
        : LoginScreen.demoEmails[random.nextInt(LoginScreen.demoEmails.length)];

    final authProvider = context.read<AuthProvider>();
    await authProvider.loginAsDemoUser();

    if (authProvider.isLoggedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (authProvider.error != null && mounted) {
      setState(() {
        _generalError = authProvider.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Header מונפש
                  LoginHeader(
                    fadeAnimation: _fadeAnimation,
                    slideAnimation: _slideAnimation,
                  ),
                  const SizedBox(height: 40),
                  // טופס התחברות
                  LoginForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    emailFocusNode: _emailFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    isPasswordVisible: _isPasswordVisible,
                    rememberMe: _rememberMe,
                    emailError: _emailError,
                    passwordError: _passwordError,
                    generalError: _generalError,
                    isLoading: _isLoading,
                    onLogin: _onLogin,
                    onPasswordVisibilityToggle: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible),
                    onRememberMeToggle: (v) => setState(() => _rememberMe = v),
                    onForgotPassword: _onForgotPassword,
                  ),
                  const SizedBox(height: 24),
                  // כפתורי סושיאל
                  SocialLoginButton(
                    onPressed: _onGoogleLogin,
                    icon: Icons.g_mobiledata,
                    label: 'התחבר באמצעות Google',
                    color: Colors.red,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: 16),
                  // כפתור התחברות כמשתמש דמו
                  OutlinedButton.icon(
                    onPressed: _loginAsDemoUser,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Icons.person_outline,
                      color: colors.primary,
                    ),
                    label: Text(
                      'התחבר כמשתמש דמו',
                      style: GoogleFonts.assistant(
                        color: colors.onSurface,
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
