// lib/screens/profile/widgets/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_model.dart';
import 'profile_avatar.dart';
import '../../../theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final Animation<double> scaleAnimation;
  final VoidCallback onEditProfile;
  final VoidCallback onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.scaleAnimation,
    required this.onEditProfile,
    required this.onAvatarTap,
  });

  static const double _avatarSize = 100.0;

  String get _displayName => user.name.isNotEmpty ? user.name : 'משתמש דמו';
  String get _displayEmail =>
      user.email.isNotEmpty ? user.email : 'demo@gymovo.com';
  String get _userStatus => 'מתאמן פעיל'; // ניתן להרחיב לוגיקה בעתיד

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primary,
                colors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                ScaleTransition(
                  scale: scaleAnimation,
                  child: _buildProfileAvatar(colors),
                ),
                const SizedBox(height: 16),
                _buildUserInfo(colors),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          tooltip: 'ערוך פרופיל',
          onPressed: () {
            HapticFeedback.lightImpact();
            onEditProfile();
          },
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(AppColors colors) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ProfileAvatar(
            user: user,
            size: _avatarSize,
            onTap: onAvatarTap,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Material(
            color: colors.secondary,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.lightImpact();
                onAvatarTap();
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(AppColors colors) {
    return Column(
      children: [
        Text(
          _displayName,
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _displayEmail,
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                _userStatus,
                style: GoogleFonts.assistant(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
