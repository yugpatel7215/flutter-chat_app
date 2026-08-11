import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/presentation/widgets/friendship_section.dart';
import 'package:chat_app/features/friends/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final UserModel userModel;

  const UserProfilePage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            // Profile information
            ProfileHeader(userModel: userModel),

            const SizedBox(height: 8),

            // Friendship actions
            FriendshipSection(user: userModel),

            const SizedBox(height: 32),

            Divider(
              indent: 24,
              endIndent: 24,
              color: colorScheme.outlineVariant,
            ),

            const SizedBox(height: 20),

            // Username
            _ProfileInfoRow(
              icon: Icons.alternate_email,
              label: 'Username',
              value: userModel.username,
            ),

            if (userModel.email.isNotEmpty) ...[
              const SizedBox(height: 16),

              _ProfileInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: userModel.email,
              ),
            ],
          ],
        ),
      ),
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
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
