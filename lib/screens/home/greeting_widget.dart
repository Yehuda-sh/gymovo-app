// lib/screens/home/greeting_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';

class GreetingWidget extends StatefulWidget {
  final UserModel? user;
  const GreetingWidget({super.key, this.user});

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  late final Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _iconAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'בוקר טוב';
    if (hour < 17) return 'צהריים טובים';
    return 'ערב טוב';
  }

  IconData _getIcon(int hour) {
    if (hour < 12) return Icons.wb_sunny;
    if (hour < 17) return Icons.wb_sunny_outlined;
    return Icons.nightlight;
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = _getGreeting(hour);
    final name = widget.user?.name ?? 'אורח';

    return Semantics(
      label: '$greeting, $name! מוכנים לשבור שיאים היום?',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4facfe),
              Color(0xFF00f2fe),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4facfe).withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
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
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _iconAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: _iconAnimation.value),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getIcon(hour),
                        color: Colors.white,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Padding(
                        padding: EdgeInsets.only(left: value * 10),
                        child: child,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $name! 💪',
                          style: GoogleFonts.assistant(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'מוכנים לשבור שיאים היום? 🔥',
                          style: GoogleFonts.assistant(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
