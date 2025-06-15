// lib/screens/settings/settings_screen.dart
// --------------------------------------------------
// מסך הגדרות ראשי
// --------------------------------------------------
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'הגדרות',
          style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.primary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // כותרת הגדרות כלליות
          Text(
            'הגדרות כלליות',
            style: GoogleFonts.assistant(
              fontWeight: FontWeight.bold,
              fontSize: 19,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 18),
          // שינוי שפה
          ListTile(
            leading: Icon(Icons.language, color: colors.primary),
            title: const Text('שפה'),
            subtitle: Text(
                settingsProvider.languageCode == 'he' ? 'עברית' : 'English'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('בחירת שפה'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('עברית'),
                        trailing: settingsProvider.languageCode == 'he'
                            ? Icon(Icons.check, color: colors.primary)
                            : null,
                        onTap: () {
                          settingsProvider.setLanguage('he');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        title: const Text('English'),
                        trailing: settingsProvider.languageCode == 'en'
                            ? Icon(Icons.check, color: colors.primary)
                            : null,
                        onTap: () {
                          settingsProvider.setLanguage('en');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),
          // התראות
          SwitchListTile(
            secondary: Icon(Icons.notifications_active, color: colors.primary),
            title: const Text('קבל התראות'),
            value: settingsProvider.notificationsEnabled,
            onChanged: (val) {
              settingsProvider.toggleNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    val ? 'התראות הופעלו' : 'התראות בוטלו',
                    style: GoogleFonts.assistant(),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const Divider(),
          // אודות
          ListTile(
            leading: Icon(Icons.info_outline, color: colors.primary),
            title: const Text('אודות האפליקציה'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Gymovo',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/images/gymovo_logo.png',
                  height: 48,
                  semanticLabel: 'לוגו Gymovo',
                ),
                children: [
                  const SizedBox(height: 10),
                  const Text('אפליקציה מותאמת אישית לתוכניות כושר והתקדמות.'),
                  const SizedBox(height: 8),
                  const Text('פותח על ידי יהודה וצוות Gymovo.'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.email),
                        label: const Text('העתק אימייל'),
                        onPressed: () {
                          // TODO: Implement email copy
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('האימייל הועתק ללוח')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.language),
                        label: const Text('בקר באתר'),
                        onPressed: () => _launchUrl('https://gymovo.com'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const Divider(),
          // קשר
          ListTile(
            leading: Icon(Icons.mail_outline, color: colors.primary),
            title: const Text('צור קשר'),
            trailing: const Icon(Icons.chevron_left),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('צור קשר'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('שלח אימייל'),
                        onTap: () {
                          _launchUrl('mailto:support@gymovo.com');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('התקשר אלינו'),
                        onTap: () {
                          _launchUrl('tel:+972123456789');
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.chat),
                        title: const Text('צ\'אט תמיכה'),
                        onTap: () {
                          // TODO: Implement chat support
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('צ\'אט תמיכה יפתח בקרוב')),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('סגור'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
