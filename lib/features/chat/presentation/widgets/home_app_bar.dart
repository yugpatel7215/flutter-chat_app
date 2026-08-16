import 'package:chat_app/features/friends/presentation/widgets/notification_bell.dart';

import 'package:chat_app/features/profile/presentation/widget/animated_profile_photo.dart';
import 'package:chat_app/features/profile/providers/profile_provider.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onFriendRequestsTap;
  final VoidCallback onSignOut;
  final bool isSigningOut;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
    required this.onFriendRequestsTap,
    required this.onSignOut,
    required this.isSigningOut,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: _buildProfileAvatar(ref),

      title: const Text('Chats', style: TextStyle(fontWeight: FontWeight.bold)),

      actions: [
        _buildNotificationBell(ref),

        IconButton(
          tooltip: 'Sign out',
          onPressed: isSigningOut ? null : onSignOut,
          icon: isSigningOut
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_outlined),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileAvatar(WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: CircleAvatar(child: Icon(Icons.person)),
      );
    }

    final profileAsync = ref.watch(getProfileData(currentUser.uid));

    return profileAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(8),
        child: CircleAvatar(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),

      error: (_, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedProfileAvatar(
          onTap: onProfileTap,
          child: const CircleAvatar(radius: 20, child: Icon(Icons.person)),
        ),
      ),

      data: (user) {
        final hasPhoto = user.photoUrl.trim().isNotEmpty;

        return Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedProfileAvatar(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 20,
              foregroundImage: hasPhoto ? NetworkImage(user.photoUrl) : null,
              child: hasPhoto ? null : const Icon(Icons.person),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell(WidgetRef ref) {
    final incomingRequestsAsync = ref.watch(getIncomingRequests);

    final requestCount = incomingRequestsAsync.value?.length ?? 0;

    return NotificationBell(count: requestCount, onTap: onFriendRequestsTap);
  }
}
