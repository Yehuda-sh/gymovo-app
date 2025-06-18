// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// מחלקה לניהול צבעים דינמי
class AppColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color text;
  final Color error;
  final Color headline;
  final Color success;
  final Color warning;
  final Color iconAccent;
  final Color gradientStart;
  final Color gradientEnd;
  final Color cardGradientStart;
  final Color cardGradientEnd;
  final Color surfaceHover;
  final Color divider;
  final Color shadow;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.text,
    required this.error,
    required this.headline,
    required this.success,
    required this.warning,
    required this.iconAccent,
    required this.gradientStart,
    required this.gradientEnd,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.surfaceHover,
    required this.divider,
    required this.shadow,
  });

  /// ערכת צבעים פרימיום
  static const premium = AppColors(
    primary: Color(0xFF1A237E),
    secondary: Color(0xFF00BCD4),
    accent: Color(0xFFFFD700),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    surfaceVariant: Color(0xFF22243A),
    outline: Color(0xFF34385A),
    text: Colors.white,
    error: Color(0xFFCF6679),
    headline: Color(0xFF5472FF),
    success: Color(0xFF00E676),
    warning: Color(0xFFFFA000),
    iconAccent: Color(0xFFEEA727),
    gradientStart: Color(0xFF1A237E),
    gradientEnd: Color(0xFF0D47A1),
    cardGradientStart: Color(0xFF22243A),
    cardGradientEnd: Color(0xFF1E1E1E),
    surfaceHover: Color(0xFF2A2A2A),
    divider: Color(0xFF34385A),
    shadow: Color(0x40000000),
  );
}

class AppTheme {
  static final AppColors colors = AppColors.premium;

  // Cache all commonly used styles
  static late final TextTheme _cachedTextTheme = GoogleFonts.assistantTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: colors.text,
    displayColor: colors.text,
  );

  // Pre-calculate and cache commonly used styles
  static late final TextStyle _displayLargeStyle =
      _cachedTextTheme.displayLarge?.copyWith(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ) ??
          const TextStyle();

  static late final TextStyle _headlineLargeStyle =
      _cachedTextTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ) ??
          const TextStyle();

  static late final TextStyle _headlineSmallStyle =
      _cachedTextTheme.headlineSmall?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ) ??
          const TextStyle();

  static late final TextStyle _titleLargeStyle =
      _cachedTextTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ) ??
          const TextStyle();

  static late final TextStyle _titleMediumStyle =
      _cachedTextTheme.titleMedium?.copyWith(
            fontSize: 18,
            color: Colors.white70,
          ) ??
          const TextStyle();

  static late final TextStyle _labelLargeStyle =
      _cachedTextTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ) ??
          const TextStyle();

  static late final TextStyle _bodyLargeStyle =
      _cachedTextTheme.bodyLarge?.copyWith(
            fontSize: 18,
          ) ??
          const TextStyle();

  static late final TextStyle _bodyMediumStyle =
      _cachedTextTheme.bodyMedium?.copyWith(
            fontSize: 16,
          ) ??
          const TextStyle();

  static late final TextStyle _bodySmallStyle =
      _cachedTextTheme.bodySmall?.copyWith(
            fontSize: 13,
            color: Colors.white60,
          ) ??
          const TextStyle();

  // Cache the entire theme
  static late final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.assistant().fontFamily,
    primaryColor: colors.primary,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.dark(
      primary: colors.primary,
      secondary: colors.secondary,
      surface: colors.surface,
      error: colors.error,
      outline: colors.outline,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.black,
      brightness: Brightness.dark,
    ),
    textTheme: _cachedTextTheme.copyWith(
      displayLarge: _displayLargeStyle,
      headlineLarge: _headlineLargeStyle,
      headlineSmall: _headlineSmallStyle,
      titleLarge: _titleLargeStyle,
      titleMedium: _titleMediumStyle,
      labelLarge: _labelLargeStyle,
      bodyLarge: _bodyLargeStyle,
      bodyMedium: _bodyMediumStyle,
      bodySmall: _bodySmallStyle,
    ),
    tabBarTheme: TabBarThemeData(
      indicatorColor: colors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: colors.accent,
      unselectedLabelColor: Colors.white60,
      labelStyle: _labelLargeStyle.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: colors.accent,
      ),
      unselectedLabelStyle: _labelLargeStyle.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: Colors.white60,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: colors.accent,
          width: 3,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.primary,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: _titleLargeStyle,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.outline.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
      ),
      labelStyle: TextStyle(color: colors.text.withOpacity(0.7)),
      hintStyle: TextStyle(color: colors.text.withOpacity(0.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.primary.withOpacity(0.8);
          }
          return colors.primary;
        }),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )),
        textStyle: WidgetStatePropertyAll(_labelLargeStyle),
        shadowColor: WidgetStatePropertyAll(colors.shadow),
        elevation: const WidgetStatePropertyAll(4),
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: colors.shadow,
    ),
    iconTheme: IconThemeData(
      color: colors.headline,
      size: 28,
    ),
    dividerColor: colors.divider,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.primary,
      contentTextStyle: _labelLargeStyle.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.accent,
      unselectedItemColor: Colors.white60,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: colors.surface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Return the cached theme
  static ThemeData get darkTheme => _darkTheme;
}
