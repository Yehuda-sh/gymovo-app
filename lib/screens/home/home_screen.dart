// lib/screens/home/home_screen.dart
// --------------------------------------------------
// מסך הבית הראשי של האפליקציה - גרסה משופרת
// --------------------------------------------------
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../splash/splash_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../features/home/screens/home_tab.dart';
import '../../features/workouts/screens/workouts_screen.dart';
import '../../providers/week_plan_provider.dart';
import '../../providers/workouts_provider.dart';
import '../../providers/exercise_history_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeTab(onTabChange: _onItemTapped),
      const WorkoutsScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _showLogoutDialog() async {
    final colors = AppTheme.colors;
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'התנתקות',
          style: GoogleFonts.assistant(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'האם אתה בטוח שברצונך להתנתק?',
          style: GoogleFonts.assistant(color: colors.text),
          textDirection: TextDirection.rtl,
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'התנתק',
              style: GoogleFonts.assistant(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    try {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'שגיאה בהתנתקות: ${e.toString()}',
              style: GoogleFonts.assistant(),
            ),
            backgroundColor: AppTheme.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeekPlanProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutsProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseHistoryProvider()),
      ],
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: _buildAppBar(colors),
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(colors),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/gymovo_logo.png',
              height: 36,
              width: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Gymovo',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: colors.headline,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout_rounded, color: colors.headline),
          tooltip: 'התנתק',
          onPressed: _showLogoutDialog,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNavigationBar(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.headline.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        indicatorColor: colors.primary.withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'בית',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'אימונים',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'פרופיל',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'הגדרות',
          ),
        ],
      ),
    );
  }
}
