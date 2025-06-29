// lib/screens/profile/profile_screen.dart
// --------------------------------------------------
// מסך פרופיל משתמש משופר עם רכיבים נפרדים ושילוב SettingsProvider
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'widgets/profile_header.dart';
import 'widgets/user_stats_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/settings_section.dart';
import 'widgets/account_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoadingLogout = false;

  // קבועים
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const List<String> _availableLanguages = [
    'עברית',
    'English',
    'العربية'
  ];
  static const List<String> _availableThemes = ['בהיר', 'כהה', 'אוטומטי'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // טעינת הגדרות מה-SettingsProvider תתבצע ב-build
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    try {
      final settings = context.read<SettingsProvider>();
      await settings.toggleNotifications();
      HapticFeedback.selectionClick();
      _showSuccessSnackBar(enabled ? 'התראות הופעלו' : 'התראות כובו');
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת הגדרות התראות');
    }
  }

  Future<void> _saveLanguagePreference(String language) async {
    try {
      final settings = context.read<SettingsProvider>();
      await settings.setLanguage(language);

      if (language != 'עברית') {
        _showComingSoonSnackBar('תמיכה ב-$language');
      } else {
        _showSuccessSnackBar('השפה שונתה לעברית');
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת בחירת שפה');
    }
  }

  Future<void> _saveThemePreference(String theme) async {
    // כרגע שמירת נושא ב-SharedPreferences לא מיושמת, תוסיף אם תרצה
    if (theme != 'בהיר') {
      _showComingSoonSnackBar('נושא $theme');
    } else {
      _showSuccessSnackBar('הנושא שונה לבהיר');
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed != true) return;

    setState(() => _isLoadingLogout = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        _showSuccessSnackBar('התנתקת בהצלחה');
        // ניווט למסך כניסה אם צריך:
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('שגיאה בהתנתקות: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLogout = false);
      }
    }
  }

  Future<bool?> _showLogoutConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: AppTheme.colors.error, size: 24),
            const SizedBox(width: 12),
            Text(
              'התנתקות',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.bold,
                color: AppTheme.colors.headline,
              ),
            ),
          ],
        ),
        content: Text(
          'האם אתה בטוח שברצונך להתנתק מהחשבון?',
          style: GoogleFonts.assistant(
            color: AppTheme.colors.text,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(
                color: AppTheme.colors.text.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'התנתק',
              style: GoogleFonts.assistant(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final settings = context.read<SettingsProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.language, color: AppTheme.colors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              'בחר שפה',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.bold,
                color: AppTheme.colors.headline,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableLanguages.map((language) {
            return RadioListTile<String>(
              title: Text(language,
                  style: GoogleFonts.assistant(color: AppTheme.colors.text)),
              value: language,
              groupValue: settings.languageCode,
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  _saveLanguagePreference(value);
                }
              },
              activeColor: AppTheme.colors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    final settings = context.read<SettingsProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.palette, color: AppTheme.colors.primary, size: 24),
            const SizedBox(width: 12),
            Text(
              'בחר נושא',
              style: GoogleFonts.assistant(
                fontWeight: FontWeight.bold,
                color: AppTheme.colors.headline,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _availableThemes.map((theme) {
            IconData themeIcon;
            switch (theme) {
              case 'בהיר':
                themeIcon = Icons.light_mode;
                break;
              case 'כהה':
                themeIcon = Icons.dark_mode;
                break;
              default:
                themeIcon = Icons.brightness_auto;
            }

            return RadioListTile<String>(
              title: Row(
                children: [
                  Icon(themeIcon, size: 20),
                  const SizedBox(width: 8),
                  Text(theme,
                      style:
                          GoogleFonts.assistant(color: AppTheme.colors.text)),
                ],
              ),
              value: theme,
              groupValue: 'בהיר',
              onChanged: (value) {
                if (value != null) {
                  Navigator.pop(context);
                  _saveThemePreference(value);
                }
              },
              activeColor: AppTheme.colors.primary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Gymovo',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppTheme.colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.fitness_center, color: Colors.white, size: 30),
      ),
      children: [
        Text(
          'אפליקציית כושר מתקדמת לניהול אימונים ומעקב התקדמות.',
          style: GoogleFonts.assistant(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          'פותח עם ❤️ עבור אוהבי הכושר',
          style: GoogleFonts.assistant(
            fontStyle: FontStyle.italic,
            color: AppTheme.colors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 Gymovo. כל הזכויות שמורות.',
          style: GoogleFonts.assistant(
            fontSize: 12,
            color: AppTheme.colors.text.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.assistant())),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.assistant())),
          ],
        ),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$feature יפותח בקרוב',
                style: GoogleFonts.assistant(),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.colors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // כותרת מעוצבת
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
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
                                    color: const Color(0xFF667eea)
                                        .withOpacity(0.4),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                    spreadRadius: 0,
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
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'פרופיל',
                                              style: GoogleFonts.assistant(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'נהל את החשבון וההגדרות שלך',
                                              style: GoogleFonts.assistant(
                                                fontSize: 14,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // תוכן הפרופיל
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  // כרטיס סטטיסטיקות משתמש
                                  UserStatsCard(
                                      user: user ?? UserModel.empty()),
                                  const SizedBox(height: 20),

                                  // כרטיס פעולות מהירות
                                  QuickActionsCard(
                                    onQuestionnaireRestart: () =>
                                        _showComingSoonSnackBar('שאלון'),
                                    onShareApp: () =>
                                        _showComingSoonSnackBar('שיתוף'),
                                  ),
                                  const SizedBox(height: 20),

                                  // כרטיס הגדרות עם הערכות מה-SettingsProvider
                                  SettingsSection(
                                    notificationsEnabled:
                                        settings.notificationsEnabled,
                                    selectedLanguage: settings.languageCode,
                                    selectedTheme: _availableThemes
                                            .contains(settings.languageCode)
                                        ? settings.languageCode
                                        : 'בהיר',
                                    onNotificationChanged:
                                        _saveNotificationPreference,
                                    onLanguageTap: _showLanguageDialog,
                                    onThemeTap: _showThemeDialog,
                                  ),
                                  const SizedBox(height: 20),

                                  // כרטיס חשבון
                                  AccountSection(
                                    isLoading: _isLoadingLogout,
                                    onPrivacyTap: () => _showComingSoonSnackBar(
                                        'הגדרות פרטיות'),
                                    onHelpTap: () =>
                                        _showComingSoonSnackBar('מרכז עזרה'),
                                    onAboutTap: _showAboutDialog,
                                    onLogout: _handleLogout,
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
