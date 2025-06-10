import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/register_screen.dart';
import '../../../screens/home_screen.dart';
import '../widgets/login_form_field.dart';
import '../widgets/login_button.dart';
import '../widgets/social_login_button.dart';
import '../helpers/validation.dart';
import 'dart:math';
import '../widgets/login_header.dart';
import '../widgets/login_divider.dart';

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

  void _validateEmail() {
    setState(() {
      _emailError = LoginValidation.validateEmail(_emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError =
          LoginValidation.validatePassword(_passwordController.text);
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _emailError = null;
        _passwordError = null;
      });

      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      await authProvider.register(
        email: email,
        password: password,
        name: email.split('@')[0],
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
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _socialAuthError = 'ההתחברות עם Google נכשלה. אנא נסה שוב.';
        });
      }
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
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _socialAuthError = 'ההתחברות עם Facebook נכשלה. אנא נסה שוב.';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isFacebookLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    LoginHeader(
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                    ),
                    const SizedBox(height: 40),
                    LoginFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'אימייל',
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      onTogglePasswordVisibility: () {},
                      validator: LoginValidation.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    LoginFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'סיסמה',
                      error: _passwordError,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePasswordVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: LoginValidation.validatePassword,
                    ),
                    if (_socialAuthError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _socialAuthError!,
                        style: GoogleFonts.assistant(
                          color: colors.error,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    LoginButton(
                      onPressed: _login,
                      label: 'התחבר',
                    ),
                    const SizedBox(height: 16),
                    LoginButton(
                      onPressed: _loginAsDemoUser,
                      label: 'התחבר כמשתמש דמו',
                    ),
                    const SizedBox(height: 24),
                    LoginDivider(text: 'או התחברו עם'),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onPressed: _handleGoogleSignIn,
                            isLoading: _isGoogleLoading,
                            color: const Color(0xFFDB4437),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.facebook,
                            label: 'Facebook',
                            onPressed: _handleFacebookSignIn,
                            isLoading: _isFacebookLoading,
                            color: const Color(0xFF4267B2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'אין לכם חשבון?',
                          style: GoogleFonts.assistant(
                            color: colors.onBackground.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'הירשמו כאן',
                            style: GoogleFonts.assistant(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
