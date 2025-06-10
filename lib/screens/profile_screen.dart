// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_avatar.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser ?? UserModel.empty();

    final workouts = user.totalWorkouts?.toString() ?? '0';
    final totalHours = user.workoutHistory
            ?.fold<num>(0, (prev, e) => prev + (e.rating ?? 0)) ??
        0;
    final achievements = user.workoutHistory?.length.toString() ?? '0';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('פרופיל'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('עריכת פרופיל בקרוב')),
                );
              },
              tooltip: 'ערוך פרופיל',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ProfileAvatar(
                      user: user,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('בקרוב תוכל להעלות תמונה אישית')),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Material(
                        shape: const CircleBorder(),
                        color: Theme.of(context).colorScheme.primary,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('בקרוב תוכל להעלות תמונה אישית')),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.camera_alt,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                user.name.isNotEmpty ? user.name : 'משתמש דמו',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                user.email.isNotEmpty ? user.email : 'demo@gymovo.com',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'מתאמן',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ),
              const SizedBox(height: 32),

              // סטטיסטיקות
              _buildInfoCard(
                context,
                title: 'סטטיסטיקות',
                children: [
                  _buildStatItem(context,
                      icon: Icons.fitness_center,
                      label: 'אימונים',
                      value: workouts),
                  _buildStatItem(context,
                      icon: Icons.timer,
                      label: 'שעות אימון',
                      value: totalHours.toString()),
                  _buildStatItem(context,
                      icon: Icons.emoji_events,
                      label: 'הישגים',
                      value: achievements),
                ],
              ),
              const SizedBox(height: 18),

              // הגדרות
              _buildInfoCard(
                context,
                title: 'הגדרות חשבון',
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_none),
                    title: const Text('התראות'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {},
                  ),
                  _divider(),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('שפה'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {},
                  ),
                  _divider(),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('אבטחה'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {},
                  ),
                  _divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('התנתק'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => authProvider.logout(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, thickness: 0.8);

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.08),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
