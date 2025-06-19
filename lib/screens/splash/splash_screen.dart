// lib/screens/splash/splash_screen.dart
// --------------------------------------------------
// מסך פתיחה (Splash) משופר
// --------------------------------------------------
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../data/local_data_store.dart';
import '../../models/user_model.dart';
import '../auth/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _progressOpacity;

  bool _isLoading = true;
  String _loadingMessage = 'מאתחל...';

  @override
  void initState() {
    super.initState();

    // Hide status bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _initAnimations();
    _startAnimations();
    _initializeApp();
  }

  void _initAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotation = Tween<double>(
      begin: -0.1,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ));

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Progress animations
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _logoController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        _textController.forward();
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          _progressController.forward();
        }
      }
    }
  }

  Future<void> _loadSettings() async {
    // Load any app settings/preferences
    await Future.delayed(
        const Duration(milliseconds: 100)); // Simulated loading
  }

  Future<UserModel?> _loadUser() async {
    return LocalDataStore.getCurrentUser();
  }

  Future<void> _loadTheme() async {
    // Pre-warm theme if needed
    AppTheme.darkTheme;
  }

  Future<void> _initializeApp() async {
    try {
      // Single initial state update
      setState(() => _loadingMessage = 'טוען נתונים...');

      // Parallel loading of all required data
      await Future.wait([
        _loadSettings(),
        _loadUser(),
        _loadTheme(),
      ]);

      if (!mounted) return;

      // Single final state update
      setState(() {
        _loadingMessage = 'הכל מוכן!';
        _isLoading = false;
      });

      // Minimal delay for UX only (smooth transition)
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Restore status bar
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      // Navigate with optimized transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Single error state update
      setState(() {
        _isLoading = false;
        _loadingMessage = 'שגיאה בטעינה';
      });

      // Show error dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'שגיאה',
            style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'אירעה שגיאה בטעינת האפליקציה. אנא נסה שוב.',
            style: GoogleFonts.assistant(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeApp(); // Retry
              },
              child: Text(
                'נסה שוב',
                style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // Proper cleanup of all controllers
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _logoRotation.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                              offset: const Offset(0, 15),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/gymovo_logo.png',
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.fitness_center,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Text content
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          const Text(
                            'Gymovo',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'המקום שלך לכושר מושלם 💪',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // Loading indicator
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _progressOpacity,
                    child: Column(
                      children: [
                        if (_isLoading) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _loadingMessage,
                            style: GoogleFonts.assistant(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF43e97b),
                                  Color(0xFF38f9d7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF43e97b).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'מוכן! 🔥',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              // Version info
              const Spacer(),
              FadeTransition(
                opacity: _textOpacity,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'גרסה 1.0.0',
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
