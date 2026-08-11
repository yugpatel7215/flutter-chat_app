import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel userModel;

  const ProfileHeader({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasPhoto = userModel.photoUrl.isNotEmpty;
    final hasAbout = userModel.about.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      child: Column(
        children: [
          // Profile picture
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.25),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundImage: hasPhoto
                  ? NetworkImage(userModel.photoUrl)
                  : null,
              onForegroundImageError: hasPhoto ? (_, __) {} : null,
              child: !hasPhoto
                  ? Icon(
                      Icons.person,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            userModel.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            userModel.username,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (hasAbout) ...[
            const SizedBox(height: 12),

            // About
            Text(
              userModel.about.trim(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
