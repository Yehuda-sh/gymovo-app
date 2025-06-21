// lib/screens/profile/widgets/settings_section.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SettingsSection extends StatelessWidget {
  final bool notificationsEnabled;
  final String selectedLanguage;
  final String selectedTheme;
  final void Function(bool) onNotificationChanged;
  final VoidCallback onLanguageTap;
  final VoidCallback onThemeTap;

  const SettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.selectedLanguage,
    required this.selectedTheme,
    required this.onNotificationChanged,
    required this.onLanguageTap,
    required this.onThemeTap,
  });

  String _getLanguageDescription() {
    switch (selectedLanguage) {
      case 'עברית':
        return 'עברית (ברירת מחדל)';
      case 'English':
        return 'English (בקרוב)';
      case 'العربية':
        return 'العربية (בקרוב)';
      default:
        return selectedLanguage;
    }
  }

  String _getThemeDescription() {
    switch (selectedTheme) {
      case 'בהיר':
        return 'מצב בהיר';
      case 'כהה':
        return 'מצב כהה (בקרוב)';
      case 'אוטומטי':
        return 'לפי המערכת (בקרוב)';
      default:
        return selectedTheme;
    }
  }

  IconData _getThemeIcon() {
    switch (selectedTheme) {
      case 'בהיר':
        return Icons.light_mode_outlined;
      case 'כהה':
        return Icons.dark_mode_outlined;
      case 'אוטומטי':
        return Icons.brightness_auto_outlined;
      default:
        return Icons.palette_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

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
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'הגדרות',
                  style: GoogleFonts.assistant(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.headline,
                  ),
                ),
              ],
            ),
          ),

          // התראות
          _buildSettingTile(
            title: 'התראות',
            subtitle: notificationsEnabled
                ? 'קבל התראות על אימונים ועדכונים'
                : 'התראות מכובות',
            icon: notificationsEnabled
                ? Icons.notifications_outlined
                : Icons.notifications_off_outlined,
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                onNotificationChanged(value);
              },
              activeColor: colors.primary,
            ),
            colors: colors,
          ),

          _buildDivider(colors),

          // שפה
          _buildSettingTile(
            title: 'שפה',
            subtitle: _getLanguageDescription(),
            icon: Icons.language_outlined,
            onTap: () {
              HapticFeedback.lightImpact();
              onLanguageTap();
            },
            colors: colors,
          ),

          _buildDivider(colors),

          // נושא
          _buildSettingTile(
            title: 'נושא',
            subtitle: _getThemeDescription(),
            icon: _getThemeIcon(),
            onTap: () {
              HapticFeedback.lightImpact();
              onThemeTap();
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
    required AppColors colors,
    Color? iconColor,
    Color? textColor,
  }) {
    final effectiveIconColor = iconColor ?? colors.primary;
    final effectiveTextColor = textColor ?? colors.headline;

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: '$title: $subtitle',
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveIconColor.withOpacity(0.1),
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
            color: colors.text.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_left,
                    color: colors.text.withOpacity(0.5),
                  )
                : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Widget _buildDivider(AppColors colors) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: colors.text.withOpacity(0.1),
      indent: 68,
      endIndent: 20,
    );
  }
}
