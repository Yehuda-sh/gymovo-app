// lib/screens/home/greeting_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';

class GreetingWidget extends StatelessWidget {
  final UserModel? user;
  const GreetingWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'בוקר טוב'
        : hour < 17
            ? 'צהריים טובים'
            : 'ערב טוב';
    final name = user?.name ?? 'אורח';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.blue.withOpacity(0.08)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name! 👋',
            style: GoogleFonts.assistant(
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'מוכנים לאימון היום? 💪',
            style: GoogleFonts.assistant(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
