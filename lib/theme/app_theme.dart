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

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.assistantTextTheme(
      ThemeData.dark().textTheme,
    ).apply(
      bodyColor: colors.text,
      displayColor: colors.text,
    );

    return ThemeData(
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
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          color: Colors.white70,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 18,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 16,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 13,
          color: Colors.white60,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: colors.accent,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colors.accent,
        unselectedLabelColor: Colors.white60,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: colors.accent,
        ),
        unselectedLabelStyle: textTheme.labelLarge?.copyWith(
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
        titleTextStyle: textTheme.titleLarge,
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
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return colors.primary.withOpacity(0.8);
            }
            return colors.primary;
          }),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          )),
          textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
          shadowColor: MaterialStatePropertyAll(colors.shadow),
          elevation: const MaterialStatePropertyAll(4),
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
        contentTextStyle: textTheme.labelLarge?.copyWith(
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
  }
}
