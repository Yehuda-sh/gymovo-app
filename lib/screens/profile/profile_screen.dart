// lib/screens/profile/profile_screen.dart
// --------------------------------------------------
// מסך פרופיל משתמש ראשי - גרסה משופרת
// --------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile_avatar.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../questionnaire/questionnaire_screen.dart';

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

  bool _notificationsEnabled = true;
  String _selectedLanguage = 'עברית';
  bool _isLoading = false;

  // קבועים פרטיים
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const List<String> _availableLanguages = [
    'עברית',
    'English',
    'العربية'
  ];
  static const double _avatarSize = 100.0;
  static const double _cardBorderRadius = 20.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutConfirmation();
    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          _showSuccessSnackBar('התנתקת בהצלחה');
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
  }

  Future<bool?> _showLogoutConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'התנתקות',
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.headline,
          ),
        ),
        content: Text(
          'האם אתה בטוח שברצונך להתנתק?',
          style: GoogleFonts.assistant(
            color: AppTheme.colors.text,
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature יפותח בקרוב',
          style: GoogleFonts.assistant(),
        ),
        backgroundColor: AppTheme.colors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser ?? UserModel.empty();
    final colors = AppTheme.colors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(user, colors),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildUserInfo(user, colors),
                      const SizedBox(height: 24),
                      _buildStatsSection(user, colors),
                      const SizedBox(height: 20),
                      _buildQuickActions(colors),
                      const SizedBox(height: 20),
                      _buildSettingsSection(colors),
                      const SizedBox(height: 20),
                      _buildAccountSection(colors),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(UserModel user, AppColors colors) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primary,
                colors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildProfileAvatar(user, colors),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          onPressed: () => _showComingSoonSnackBar('עריכת פרופיל'),
          tooltip: 'ערוך פרופיל',
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(UserModel user, AppColors colors) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ProfileAvatar(
            user: user,
            onTap: () => _showComingSoonSnackBar('העלאת תמונה'),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              shape: const CircleBorder(),
              color: colors.secondary,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showComingSoonSnackBar('העלאת תמונה');
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(UserModel user, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            user.name.isNotEmpty ? user.name : 'משתמש דמו',
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.headline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email.isNotEmpty ? user.email : 'demo@gymovo.com',
            style: GoogleFonts.assistant(
              fontSize: 16,
              color: colors.text.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withOpacity(0.1),
                  colors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 16,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'מתאמן פעיל',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserModel user, AppColors colors) {
    final workouts = user.totalWorkouts?.toString() ?? '0';
    final totalHours = user.workoutHistory
            ?.fold<num>(0, (prev, e) => prev + (e.rating ?? 0)) ??
        0;
    final achievements = user.workoutHistory?.length.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: colors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'הסטטיסטיקות שלי',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'אימונים',
                  workouts,
                  Icons.fitness_center,
                  colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'שעות',
                  totalHours.toString(),
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'הישגים',
                  achievements,
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.headline,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.assistant(
              fontSize: 12,
              color: AppTheme.colors.text.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: colors.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'פעולות מהירות',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'שאלון מחדש',
                  Icons.assignment_outlined,
                  colors.primary,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuestionnaireScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'שתף אפליקציה',
                  Icons.share_outlined,
                  colors.secondary,
                  () => _showComingSoonSnackBar('שיתוף'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(AppColors colors) {
    return _buildInfoCard(
      colors,
      title: 'הגדרות',
      icon: Icons.settings_outlined,
      children: [
        _buildSettingTile(
          'התראות',
          'קבל התראות על אימונים ועדכונים',
          Icons.notifications_outlined,
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              HapticFeedback.selectionClick();
            },
            activeColor: colors.primary,
          ),
        ),
        _buildDivider(),
        _buildSettingTile(
          'שפה',
          _selectedLanguage,
          Icons.language_outlined,
          onTap: () => _showLanguageDialog(),
        ),
        _buildDivider(),
        _buildSettingTile(
          'נושא',
          'בהיר',
          Icons.palette_outlined,
          onTap: () => _showComingSoonSnackBar('שינוי נושא'),
        ),
      ],
    );
  }

  Widget _buildAccountSection(AppColors colors) {
    return _buildInfoCard(
      colors,
      title: 'חשבון',
      icon: Icons.account_circle_outlined,
      children: [
        _buildSettingTile(
          'פרטיות ואבטחה',
          'נהל את הפרטיות שלך',
          Icons.security_outlined,
          onTap: () => _showComingSoonSnackBar('הגדרות פרטיות'),
        ),
        _buildDivider(),
        _buildSettingTile(
          'עזרה ותמיכה',
          'קבל עזרה ותמיכה טכנית',
          Icons.help_outline,
          onTap: () => _showComingSoonSnackBar('מרכז עזרה'),
        ),
        _buildDivider(),
        _buildSettingTile(
          'אודות האפליקציה',
          'מידע על הגרסה ופיתוח',
          Icons.info_outline,
          onTap: () => _showAboutDialog(),
        ),
        _buildDivider(),
        _buildSettingTile(
          'התנתק',
          'התנתק מהחשבון שלך',
          Icons.logout,
          onTap: _handleLogout,
          textColor: colors.error,
          iconColor: colors.error,
          showLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    AppColors colors, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.headline,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
    bool showLoading = false,
  }) {
    final colors = AppTheme.colors;

    return ListTile(
      leading: showLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            )
          : Icon(
              icon,
              color: iconColor ?? colors.text.withOpacity(0.7),
            ),
      title: Text(
        title,
        style: GoogleFonts.assistant(
          fontWeight: FontWeight.w600,
          color: textColor ?? colors.headline,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.assistant(
          color: colors.text.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_left,
            color: colors.text.withOpacity(0.5),
          ),
      onTap: showLoading ? null : onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppTheme.colors.text.withOpacity(0.1),
      indent: 56,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'בחר שפה',
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.headline,
          ),
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
                  setState(() => _selectedLanguage = value);
                  Navigator.pop(context);
                  if (value != 'עברית') {
                    _showComingSoonSnackBar('תמיכה ב$value');
                  }
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
        child: const Icon(
          Icons.fitness_center,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        Text(
          'אפליקציית כושר מתקדמת לניהול אימונים ומעקב התקדמות.',
          style: GoogleFonts.assistant(),
        ),
        const SizedBox(height: 16),
        Text(
          'פותח עם ❤️ עבור אוהבי הכושר',
          style: GoogleFonts.assistant(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
