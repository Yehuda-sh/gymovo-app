// lib/screens/profile/profile_screen.dart
// --------------------------------------------------
// מסך פרופיל משתמש משופר עם רכיבים נפרדים
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'widgets/profile_header.dart';
import 'widgets/user_stats_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/settings_section.dart';
import 'widgets/account_section.dart';

/// מסך פרופיל משתמש ראשי
///
/// תכונות:
/// - תצוגת פרופיל עם אנימציות
/// - סטטיסטיקות משתמש
/// - הגדרות ופעולות מהירות
/// - ניהול חשבון ותמיכה
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

  // מצבי הגדרות
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'עברית';
  String _selectedTheme = 'בהיר';
  bool _isLoading = false;

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
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  /// מגדיר את האנימציות
  void _setupAnimations() {
    _fadeAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));

    // התחל אנימציות
    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  /// טוען העדפות משתמש מ-SharedPreferences
  Future<void> _loadUserPreferences() async {
    try {
      // TODO: טען העדפות אמיתיות מ-SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // setState(() {
      //   _notificationsEnabled = prefs.getBool('notifications') ?? true;
      //   _selectedLanguage = prefs.getString('language') ?? 'עברית';
      //   _selectedTheme = prefs.getString('theme') ?? 'בהיר';
      // });
    } catch (e) {
      debugPrint('שגיאה בטעינת העדפות משתמש: $e');
    }
  }

  /// שומר העדפת התראות
  Future<void> _saveNotificationPreference(bool enabled) async {
    try {
      setState(() => _notificationsEnabled = enabled);
      // TODO: שמור ב-SharedPreferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setBool('notifications', enabled);

      HapticFeedback.selectionClick();
      _showSuccessSnackBar(enabled ? 'התראות הופעלו' : 'התראות כובו');
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת הגדרות התראות');
    }
  }

  /// שומר בחירת שפה
  Future<void> _saveLanguagePreference(String language) async {
    try {
      setState(() => _selectedLanguage = language);
      // TODO: שמור ב-SharedPreferences ויישם שינוי שפה
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('language', language);

      if (language != 'עברית') {
        _showComingSoonSnackBar('תמיכה ב$language');
      } else {
        _showSuccessSnackBar('השפה שונתה לעברית');
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת בחירת שפה');
    }
  }

  /// שומר בחירת נושא
  Future<void> _saveThemePreference(String theme) async {
    try {
      setState(() => _selectedTheme = theme);
      // TODO: שמור ב-SharedPreferences ויישם שינוי נושא
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('theme', theme);

      if (theme != 'בהיר') {
        _showComingSoonSnackBar('נושא $theme');
      } else {
        _showSuccessSnackBar('הנושא שונה לבהיר');
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת בחירת נושא');
    }
  }

  /// מטפל בהתנתקות עם אישור
  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      if (mounted) {
        _showSuccessSnackBar('התנתקת בהצלחה');
        // ניווט למסך כניסה אם צריך
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('שגיאה בהתנתקות: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// מציג דיאלוג אישור התנתקות
  Future<bool?> _showLogoutConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: AppTheme.colors.error,
              size: 24,
            ),
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

  /// מציג דיאלוג בחירת שפה
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.language,
              color: AppTheme.colors.primary,
              size: 24,
            ),
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
              title: Text(
                language,
                style: GoogleFonts.assistant(
                  color: AppTheme.colors.text,
                ),
              ),
              value: language,
              groupValue: _selectedLanguage,
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

  /// מציג דיאלוג בחירת נושא
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.palette,
              color: AppTheme.colors.primary,
              size: 24,
            ),
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
                  Text(
                    theme,
                    style: GoogleFonts.assistant(
                      color: AppTheme.colors.text,
                    ),
                  ),
                ],
              ),
              value: theme,
              groupValue: _selectedTheme,
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

  /// מציג דיאלוג אודות
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
        child: const Icon(
          Icons.fitness_center,
          color: Colors.white,
          size: 30,
        ),
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

  // פונקציות הודעות
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: GoogleFonts.assistant()),
            ),
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
            Expanded(
              child: Text(message, style: GoogleFonts.assistant()),
            ),
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
    final colors = AppTheme.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.currentUser ?? UserModel.empty();

            return FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // כותרת עם פרופיל
                  ProfileHeader(
                    user: user,
                    scaleAnimation: _scaleAnimation,
                    onEditProfile: () =>
                        _showComingSoonSnackBar('עריכת פרופיל'),
                    onAvatarTap: () => _showComingSoonSnackBar('העלאת תמונה'),
                  ),

                  // תוכן הדף
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // סטטיסטיקות משתמש
                          UserStatsCard(user: user),
                          const SizedBox(height: 20),

                          // פעולות מהירות
                          QuickActionsCard(
                            onQuestionnaireRestart: () =>
                                _showComingSoonSnackBar('שאלון'),
                            onShareApp: () => _showComingSoonSnackBar('שיתוף'),
                          ),
                          const SizedBox(height: 20),

                          // הגדרות
                          SettingsSection(
                            notificationsEnabled: _notificationsEnabled,
                            selectedLanguage: _selectedLanguage,
                            selectedTheme: _selectedTheme,
                            onNotificationChanged: _saveNotificationPreference,
                            onLanguageTap: _showLanguageDialog,
                            onThemeTap: _showThemeDialog,
                          ),
                          const SizedBox(height: 20),

                          // ניהול חשבון
                          AccountSection(
                            isLoading: _isLoading,
                            onPrivacyTap: () =>
                                _showComingSoonSnackBar('הגדרות פרטיות'),
                            onHelpTap: () =>
                                _showComingSoonSnackBar('מרכז עזרה'),
                            onAboutTap: _showAboutDialog,
                            onLogout: _handleLogout,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
