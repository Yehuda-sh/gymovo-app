import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/register/register_screen.dart';
import '../../../screens/home/home_screen.dart';
import '../widgets/login_form_field.dart';
import '../widgets/login_button.dart';
import '../widgets/social_login_button.dart';
import '../helpers/validation.dart';
import 'dart:math';
import '../widgets/login_header.dart';
import '../widgets/login_divider.dart';

// Enums for better state management
enum AuthMethod { email, google, facebook, demo }

enum LoginState { idle, loading, success, error }

// Constants
class LoginConstants {
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration socialLoginDelay = Duration(seconds: 2);
  static const Duration successNavigationDelay = Duration(milliseconds: 500);
  static const String demoPassword = 'demoUser123';
  static const int demoEmailCount = 10;

  // Dev mode test users
  static const List<TestUser> testUsers = [
    TestUser(email: 'admin@gymovo.com', password: 'admin123', name: 'Admin'),
    TestUser(email: 'user1@test.com', password: 'test123', name: 'Test User 1'),
    TestUser(email: 'developer@dev.com', password: 'dev123', name: 'Developer'),
    TestUser(email: 'qa@quality.com', password: 'qa123', name: 'QA Tester'),
    TestUser(
        email: 'trainer@gym.com',
        password: 'trainer123',
        name: 'Personal Trainer'),
  ];
}

class TestUser {
  final String email;
  final String password;
  final String name;

  const TestUser({
    required this.email,
    required this.password,
    required this.name,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Form and controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // State management
  LoginState _loginState = LoginState.idle;
  AuthMethod? _currentAuthMethod;
  String? _emailError;
  String? _passwordError;
  String? _generalError;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Demo user constants
  static final List<String> _demoEmails = List.generate(
    LoginConstants.demoEmailCount,
    (i) => 'demo${i + 1}@gymovo.com',
  );

  // Helper method to get random demo email
  String get _randomDemoEmail {
    final random = Random();
    return _emailController.text.isNotEmpty &&
            _demoEmails.contains(_emailController.text)
        ? _emailController.text
        : _demoEmails[random.nextInt(_demoEmails.length)];
  }

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
    _setupAnimations();
    _loadSavedCredentials();
  }

  void _setupFocusListeners() {
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
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: LoginConstants.animationDuration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _loadSavedCredentials() async {
    // Load saved email if "Remember Me" was checked
    // This would typically come from SharedPreferences or secure storage
    // For now, just placeholder
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

  // Validation methods
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

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
  }

  // Enhanced validation with better UX
  bool _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      // Add haptic feedback for validation errors
      HapticFeedback.lightImpact();

      // Focus on first error field
      if (_emailError != null) {
        _emailFocusNode.requestFocus();
      } else if (_passwordError != null) {
        _passwordFocusNode.requestFocus();
      }
    }
    return isValid;
  }

  // Generic method for handling authentication with enhanced error handling
  Future<void> _handleAuth(
      AuthMethod method, Future<void> Function() authAction) async {
    if (_loginState == LoginState.loading) return;

    // Add haptic feedback
    HapticFeedback.selectionClick();

    setState(() {
      _loginState = LoginState.loading;
      _currentAuthMethod = method;
    });

    _clearErrors();
    FocusScope.of(context).unfocus();

    try {
      await authAction();
      await _handleAuthSuccess();
    } catch (error) {
      _handleAuthError(error.toString());
      HapticFeedback.heavyImpact(); // Error haptic feedback
    } finally {
      if (mounted) {
        setState(() {
          _loginState = LoginState.idle;
          _currentAuthMethod = null;
        });
      }
    }
  }

  Future<void> _handleAuthSuccess() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoggedIn && mounted) {
      setState(() {
        _loginState = LoginState.success;
      });

      // Save credentials if remember me is checked
      if (_rememberMe) {
        await _saveCredentials();
      }

      // Success haptic feedback
      HapticFeedback.mediumImpact();

      // Show success message
      _showSuccessMessage();

      // Navigate after short delay
      await Future.delayed(LoginConstants.successNavigationDelay);
      if (mounted) {
        _navigateToHome();
      }
    } else if (authProvider.error != null) {
      throw Exception(authProvider.error!);
    }
  }

  Future<void> _saveCredentials() async {
    // Save email to SharedPreferences if remember me is checked
    // Implementation would go here
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleAuthError(String error) {
    if (!mounted) return;

    setState(() {
      _loginState = LoginState.error;

      // Enhanced error categorization
      final lowerError = error.toLowerCase();
      if (lowerError.contains('אימייל') ||
          lowerError.contains('email') ||
          lowerError.contains('user not found')) {
        _emailError = error;
      } else if (lowerError.contains('סיסמה') ||
          lowerError.contains('password') ||
          lowerError.contains('wrong password')) {
        _passwordError = error;
      } else if (lowerError.contains('network') ||
          lowerError.contains('connection')) {
        _generalError = 'בעיית רשת. אנא בדוק את החיבור לאינטרנט.';
      } else {
        _generalError = error;
      }
    });
  }

  void _showSuccessMessage() {
    final methodName = _getMethodDisplayName(_currentAuthMethod);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'התחברת בהצלחה$methodName!',
                style: GoogleFonts.assistant(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _getMethodDisplayName(AuthMethod? method) {
    switch (method) {
      case AuthMethod.google:
        return ' עם Google';
      case AuthMethod.facebook:
        return ' עם Facebook';
      case AuthMethod.demo:
        return ' כמשתמש דמו';
      case AuthMethod.email:
      case null:
        return '';
    }
  }

  // Authentication methods
  Future<void> _login() async {
    if (!_validateForm()) return;

    await _handleAuth(AuthMethod.email, () async {
      final authProvider = context.read<AuthProvider>();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Check if it's actually a login or register call
      await authProvider.register(
        email: email,
        password: password,
        name: email.split('@')[0],
      );
    });
  }

  Future<void> _loginAsDemoUser() async {
    await _handleAuth(AuthMethod.demo, () async {
      // Use demo credentials
      _emailController.text = _randomDemoEmail;
      _passwordController.text = LoginConstants.demoPassword;

      final authProvider = context.read<AuthProvider>();
      await authProvider.loginAsDemoUser();
    });
  }

  Future<void> _handleSocialSignIn(AuthMethod method) async {
    await _handleAuth(method, () async {
      // Simulate social login with more realistic delay
      await Future.delayed(LoginConstants.socialLoginDelay);

      // More realistic success/failure simulation
      final random = Random();
      final success = random.nextInt(10) > 1; // 90% success rate

      if (!success) {
        final methodName = method == AuthMethod.google ? 'Google' : 'Facebook';
        throw Exception('ההתחברות עם $methodName נכשלה. אנא נסה שוב.');
      }
    });
  }

  // Wrapper methods for UI callbacks
  void _handleLogin() {
    if (!_isAnyLoading) {
      _login();
    }
  }

  void _handleDemoLogin() {
    if (!_isAnyLoading) {
      _loginAsDemoUser();
    }
  }

  void _handleGoogleLogin() {
    if (!_isAnyLoading) {
      _handleSocialSignIn(AuthMethod.google);
    }
  }

  void _handleFacebookLogin() {
    if (!_isAnyLoading) {
      _handleSocialSignIn(AuthMethod.facebook);
    }
  }

  void _handleRegisterNavigation() {
    if (!_isAnyLoading) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  void _handleForgotPassword() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('אנא הכנס כתובת אימייל תחילה'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _emailFocusNode.requestFocus();
      return;
    }

    // TODO: Implement forgot password functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('קישור לאיפוס סיסמה נשלח לכתובת ${_emailController.text}'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDemoHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('חשבונות דמו זמינים', style: GoogleFonts.assistant()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('בחר אחד מחשבונות הדמו:', style: GoogleFonts.assistant()),
            const SizedBox(height: 8),
            ..._demoEmails.take(3).map(
                  (email) => TextButton(
                    onPressed: () {
                      _emailController.text = email;
                      _passwordController.text = LoginConstants.demoPassword;
                      Navigator.pop(context);
                    },
                    child: Text(email, style: GoogleFonts.assistant()),
                  ),
                ),
            Text('סיסמה: ${LoginConstants.demoPassword}',
                style: GoogleFonts.assistant(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('סגור', style: GoogleFonts.assistant()),
          ),
        ],
      ),
    );
  }

  void _showQuickFillOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              '🚀 מילוי מהיר לפיתוח',
              style: GoogleFonts.assistant(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'בחר משתמש לכניסה מהירה',
              style: GoogleFonts.assistant(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Test users list
            ...LoginConstants.testUsers.map((user) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: GoogleFonts.assistant(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: GoogleFonts.assistant(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      user.email,
                      style: GoogleFonts.assistant(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    onTap: () {
                      _fillFormWithUser(user);
                      Navigator.pop(context);
                      HapticFeedback.selectionClick();
                    },
                  ),
                )),

            const SizedBox(height: 16),

            // Random user button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.shuffle),
                label: Text('משתמש אקראי', style: GoogleFonts.assistant()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _fillWithRandomUser();
                  Navigator.pop(context);
                  HapticFeedback.selectionClick();
                },
              ),
            ),

            const SizedBox(height: 8),

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('סגור', style: GoogleFonts.assistant()),
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _fillFormWithUser(TestUser user) {
    setState(() {
      _emailController.text = user.email;
      _passwordController.text = user.password;
      _isPasswordVisible = true; // Show password so dev can see it
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('טופס מולא עם ${user.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _fillWithRandomUser() {
    final random = Random();
    final randomUser = LoginConstants
        .testUsers[random.nextInt(LoginConstants.testUsers.length)];
    _fillFormWithUser(randomUser);
  }

  // UI Helper methods
  bool _isMethodLoading(AuthMethod method) {
    return _loginState == LoginState.loading && _currentAuthMethod == method;
  }

  bool get _isAnyLoading => _loginState == LoginState.loading;

  Widget _buildErrorMessage() {
    if (_generalError == null) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _generalError!,
              style: GoogleFonts.assistant(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        Text(
          'זכור אותי',
          style: GoogleFonts.assistant(
            fontSize: 14,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _handleForgotPassword,
          child: Text(
            'שכחת סיסמה?',
            style: GoogleFonts.assistant(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Dev Mode Quick Fill Button (only in debug mode)
                    if (kDebugMode) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: OutlinedButton.icon(
                          icon:
                              const Icon(Icons.flash_on, color: Colors.orange),
                          label: Text(
                            '⚡ מילוי מהיר (DEV)',
                            style: GoogleFonts.assistant(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.orange, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _showQuickFillOptions,
                        ),
                      ),
                    ],

                    // Header with enhanced animations
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: LoginHeader(
                            fadeAnimation: _fadeAnimation,
                            slideAnimation: _slideAnimation,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email field
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

                    // Password field
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

                    // Remember me and forgot password
                    _buildRememberMeCheckbox(),

                    // General error message
                    _buildErrorMessage(),

                    const SizedBox(height: 24),

                    // Login buttons
                    LoginButton(
                      onPressed: _handleLogin,
                      label: 'התחבר',
                      isLoading: _isMethodLoading(AuthMethod.email),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LoginButton(
                            onPressed: _handleDemoLogin,
                            label: 'התחבר כדמו',
                            isLoading: _isMethodLoading(AuthMethod.demo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _showDemoHint,
                          icon: const Icon(Icons.help_outline),
                          tooltip: 'חשבונות דמו זמינים',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    LoginDivider(text: 'או התחברו עם'),
                    const SizedBox(height: 24),

                    // Social login buttons
                    Row(
                      children: [
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onPressed: _handleGoogleLogin,
                            isLoading: _isMethodLoading(AuthMethod.google),
                            color: const Color(0xFFDB4437),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SocialLoginButton(
                            icon: Icons.facebook,
                            label: 'Facebook',
                            onPressed: _handleFacebookLogin,
                            isLoading: _isMethodLoading(AuthMethod.facebook),
                            color: const Color(0xFF4267B2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'אין לכם חשבון?',
                          style: GoogleFonts.assistant(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: _handleRegisterNavigation,
                          child: Text(
                            'הירשמו כאן',
                            style: GoogleFonts.assistant(
                              color: _isAnyLoading
                                  ? colors.onSurface.withValues(alpha: 0.4)
                                  : colors.primary,
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
