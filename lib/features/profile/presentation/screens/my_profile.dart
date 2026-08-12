import 'package:chat_app/core/navigation/app_route.dart';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/features/auth/screens/forgot_password_page.dart';
import 'package:chat_app/features/friends/presentation/screens/friends_page.dart';
import 'package:chat_app/features/profile/presentation/screens/edit_profile.dart';
import 'package:chat_app/features/profile/presentation/widget/profile_action_tile.dart';
import 'package:chat_app/features/profile/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyProfilePage extends ConsumerWidget {
  final String uid;

  const MyProfilePage({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(getProfileData(uid));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), centerTitle: true),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(getProfileData(uid));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          data: (user) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─────────────────────────────
                  // Profile Header
                  // ─────────────────────────────
                  Center(
                    child: Hero(
                      tag: 'profile-avatar-$uid',
                      child: CircleAvatar(
                        radius: 58,
                        foregroundImage: user.photoUrl.isNotEmpty
                            ? NetworkImage(user.photoUrl)
                            : null,
                        child: user.photoUrl.isEmpty
                            ? const Icon(Icons.person, size: 58)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (user.about.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      user.about,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ─────────────────────────────
                  // Profile Information
                  // ─────────────────────────────
                  Text(
                    'Profile Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _ProfileInfoRow(
                            icon: Icons.person_outline,
                            label: 'Name',
                            value: user.name,
                          ),

                          const SizedBox(height: 18),

                          _ProfileInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user.email,
                          ),

                          if (user.about.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _ProfileInfoRow(
                              icon: Icons.info_outline,
                              label: 'About',
                              value: user.about,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─────────────────────────────
                  // Account
                  // ─────────────────────────────
                  Text(
                    'Account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        ProfileActionTile(
                          icon: Icons.people_outline,
                          title: 'Friends',
                          subtitle: 'View your friends',
                          onTap: () {
                            Navigator.push(
                              context,
                              AppRoute.fade(FriendsPage()),
                            );
                          },
                        ),

                        const Divider(height: 1),

                        ProfileActionTile(
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          subtitle: 'Update your name, photo and about',
                          onTap: () {
                            Navigator.push(
                              context,
                              AppRoute.fade(EditProfilePage(uid: uid)),
                            );
                          },
                        ),

                        const Divider(height: 1),

                        ProfileActionTile(
                          icon: Icons.lock_outline,
                          title: 'Reset Password',
                          subtitle: 'Change your account password',
                          onTap: () {
                            Navigator.push(
                              context,
                              AppRoute.fade(ForgotPasswordPage()),
                            );
                          },
                        ),

                        const Divider(height: 1),

                        ProfileActionTile(
                          icon: Icons.logout,
                          title: 'Logout',
                          subtitle: 'Sign out of your account',
                          isDestructive: true,
                          onTap: () {
                            _showLogoutDialog(context, ref);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ref.read(authControllerProvider.notifier).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
