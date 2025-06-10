import 'package:flutter/material.dart';
import '../models/user_model.dart';

class GreetingHeader extends StatelessWidget {
  final UserModel user;

  const GreetingHeader({
    super.key,
    required this.user,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'בוקר טוב';
    if (hour < 18) return 'צהריים טובים';
    return 'ערב טוב';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.wb_cloudy_rounded;
    return Icons.nights_stay_rounded;
  }

  /// מחזיר נתיב אוואטר ברירת מחדל לפי מגדר
  String _getDefaultAvatarAsset() {
    final g = (user.gender?.name ?? '').toLowerCase();
    if (g == 'נקבה' || g == 'female') {
      return 'assets/images/avatar_female.png'; // הכנס את התמונה המתאימה בפרויקט
    }
    if (g == 'זכר' || g == 'male') {
      return 'assets/images/avatar_male.png'; // הכנס את התמונה המתאימה בפרויקט
    }
    return 'assets/avatars/avatar_neutral.png'; // ברירת מחדל
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryContainer = theme.colorScheme.primaryContainer;
    final onPrimaryContainer = theme.colorScheme.onPrimaryContainer;

    final greeting = _getGreeting();
    final greetingIcon = _getGreetingIcon();
    final showName = (user.name.trim().isNotEmpty);

    // בדיקת תמונת פרופיל
    Widget avatarWidget;
    if ((user.imageUrl != null && user.imageUrl!.isNotEmpty)) {
      avatarWidget = CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(user.imageUrl!),
        backgroundColor: onPrimaryContainer.withOpacity(0.13),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 28,
        backgroundImage: AssetImage(_getDefaultAvatarAsset()),
        backgroundColor: onPrimaryContainer.withOpacity(0.13),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            primaryContainer,
            primaryContainer.withOpacity(0.93),
            primaryContainer.withOpacity(0.84)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          avatarWidget,
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        showName ? user.name : 'ברוך הבא',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              greetingIcon,
              color: onPrimaryContainer,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
