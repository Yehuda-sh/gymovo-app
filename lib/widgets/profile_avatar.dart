import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel user;
  final double size;
  final VoidCallback? onTap;
  final bool showStatusDot;
  final bool showInitials;
  final bool useNickname;

  const ProfileAvatar({
    required this.user,
    this.size = 90,
    this.onTap,
    this.showStatusDot = false,
    this.showInitials = true,
    this.useNickname = false,
    super.key,
  });

  /// בוחר אווטאר לפי מגדר, ניטרלי אם לא הוגדר מגדר
  String _defaultAvatarByGender(String? gender) {
    final g = (gender ?? '').toLowerCase();
    if (g == 'נקבה' || g == 'female') {
      return 'assets/avatars/avatar_female.png';
    }
    if (g == 'זכר' || g == 'male') {
      return 'assets/avatars/avatar_male.png';
    }
    return 'assets/avatars/avatar_neutral.png';
  }

  String _initials() {
    final displayName = useNickname ? (user.nickname ?? user.name) : user.name;
    if ((displayName ?? '').isEmpty) return '';
    final parts = displayName.trim().split(' ');
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Color _getBackgroundColor() {
    final displayName = useNickname ? (user.nickname ?? user.name) : user.name;
    if (displayName.isEmpty) {
      return Colors.grey.shade200;
    }
    return Colors
        .primaries[displayName.hashCode % Colors.primaries.length].shade200;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = user.imageUrl != null && user.imageUrl!.isNotEmpty;
    final imageIsNetwork = hasImage &&
        (user.imageUrl!.startsWith('http') ||
            user.imageUrl!.startsWith('https'));
    final double statusDotSize = size / 4.3;
    final String defaultAvatar = _defaultAvatarByGender(user.gender?.name);
    final displayName = useNickname ? (user.nickname ?? user.name) : user.name;

    Widget avatarCore;
    if (hasImage) {
      avatarCore = imageIsNetwork
          ? ClipOval(
              child: Stack(
                children: [
                  FadeInImage.assetNetwork(
                    placeholder: defaultAvatar,
                    image: user.imageUrl!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                    fadeInDuration: const Duration(milliseconds: 220),
                  ),
                  if (imageIsNetwork)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : CircleAvatar(
              radius: size / 2,
              backgroundImage: AssetImage(user.imageUrl!),
            );
    } else {
      avatarCore = CircleAvatar(
        radius: size / 2,
        backgroundColor: _getBackgroundColor(),
        child: (showInitials && (displayName ?? '').isNotEmpty)
            ? Text(
                _initials(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: size / 2.2,
                  color: _getBackgroundColor().withOpacity(0.8),
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.13),
                      blurRadius: 4,
                    ),
                  ],
                ),
              )
            : null,
      );
    }

    Widget avatarWithStatus = Stack(
      clipBehavior: Clip.none,
      children: [
        avatarCore,
        if (showStatusDot)
          Positioned(
            right: 6,
            bottom: 5,
            child: Container(
              width: statusDotSize,
              height: statusDotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.greenAccent[400],
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        borderRadius: BorderRadius.circular(size),
        onTap: onTap,
        child: Tooltip(
          message: displayName ?? '',
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 230),
              child: avatarWithStatus,
            ),
          ),
        ),
      ),
    );
  }
}
