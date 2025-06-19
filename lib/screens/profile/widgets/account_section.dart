// lib/screens/profile/widgets/account_section.dart
// --------------------------------------------------
// רכיב ניהול חשבון עם אבטחה ונגישות
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

/// רכיב ניהול חשבון ותמיכה
///
/// תכונות:
/// - פרטיות ואבטחה
/// - עזרה ותמיכה
/// - מידע על האפליקציה
/// - התנתקות מאובטחת
class AccountSection extends StatelessWidget {
  /// האם בתהליך התנתקות
  final bool isLoading;

  /// פונקציה לפרטיות ואבטחה
  final VoidCallback onPrivacyTap;

  /// פונקציה לעזרה ותמיכה
  final VoidCallback onHelpTap;

  /// פונקציה למידע על האפליקציה
  final VoidCallback onAboutTap;

  /// פונקציה להתנתקות
  final VoidCallback onLogout;

  const AccountSection({
    super.key,
    required this.isLoading,
    required this.onPrivacyTap,
    required this.onHelpTap,
    required this.onAboutTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
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
          // כותרת הסקציה
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_circle_outlined,
                    color: colors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'חשבון ותמיכה',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // פרטיות ואבטחה
          _buildAccountTile(
            title: 'פרטיות ואבטחה',
            subtitle: 'נהל את הפרטיות וההגנה של החשבון',
            icon: Icons.security_outlined,
            onTap: () {
              HapticFeedback.lightImpact();
              onPrivacyTap();
            },
            colors: AppTheme.colors,
            theme: theme,
          ),

          _buildDivider(AppTheme.colors, theme),

          // עזרה ותמיכה
          _buildAccountTile(
            title: 'עזרה ותמיכה',
            subtitle: 'קבל עזרה, תמיכה טכנית ומדריכים',
            icon: Icons.help_outline,
            onTap: () {
              HapticFeedback.lightImpact();
              onHelpTap();
            },
            colors: AppTheme.colors,
            theme: theme,
          ),

          _buildDivider(AppTheme.colors, theme),

          // אודות האפליקציה
          _buildAccountTile(
            title: 'אודות האפליקציה',
            subtitle: 'מידע על הגרסה, פיתוח ורישיונות',
            icon: Icons.info_outline,
            onTap: () {
              HapticFeedback.lightImpact();
              onAboutTap();
            },
            colors: AppTheme.colors,
            theme: theme,
          ),

          _buildDivider(AppTheme.colors, theme),

          // התנתקות
          _buildAccountTile(
            title: 'התנתק',
            subtitle: isLoading ? 'מתנתק...' : 'התנתק מהחשבון שלך',
            icon: Icons.logout,
            onTap: isLoading
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onLogout();
                  },
            iconColor: colors.error,
            textColor: colors.error,
            showLoading: isLoading,
            colors: AppTheme.colors,
            theme: theme,
          ),
        ],
      ),
    );
  }

  /// בונה פריט חשבון
  Widget _buildAccountTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
    bool showLoading = false,
    required AppColors colors,
    required ThemeData theme,
  }) {
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurface;
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: showLoading ? 'מתנתק, אנא המתן' : '$title: $subtitle',
      child: ListTile(
        leading: showLoading
            ? SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colors.error),
                    ),
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 20,
                ),
              ),
        title: Text(
          title,
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.w600,
            color: effectiveTextColor,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.assistant(
            color: showLoading
                ? colors.error.withOpacity(0.8)
                : theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        trailing: showLoading
            ? null
            : Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        enabled: !showLoading,
      ),
    );
  }

  /// בונה קו מפריד
  Widget _buildDivider(AppColors colors, ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: theme.colorScheme.onSurface.withOpacity(0.13),
      indent: 68,
      endIndent: 20,
    );
  }
}
