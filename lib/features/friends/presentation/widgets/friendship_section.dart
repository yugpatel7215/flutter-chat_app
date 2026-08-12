import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/data/enum/friendship_enum.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';

class FriendshipSection extends ConsumerWidget {
  final UserModel user;

  const FriendshipSection({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationshipAsync = ref.watch(getRelationship(user.uid));

    final controller = ref.read(relationshipControllerProvider.notifier);

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return relationshipAsync.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),

      error: (error, stackTrace) {
        return Text(
          'Could not load friendship status.',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        );
      },

      data: (relationship) {
        // No relationship exists.
        if (relationship == null) {
          return _FriendshipActionButton(
            label: 'Add Friend',
            icon: Icons.person_add_outlined,
            onTap: () {
              return controller.sendFriendRequest(user);
            },
            successMessage: 'Friend request sent',
          );
        }

        switch (relationship.status) {
          // A request exists.
          case RelationshipStatus.pending:
            // Current user sent the request.
            if (relationship.senderId == currentUser.uid) {
              return _FriendshipActionButton(
                label: 'Cancel Request',
                icon: Icons.person_remove_outlined,
                outlined: true,
                onTap: () {
                  return controller.cancelFriendRequest(relationship);
                },
                successMessage: 'Friend request cancelled',
              );
            }

            // Current user received the request.
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FriendshipActionButton(
                  label: 'Accept',
                  icon: Icons.check,
                  onTap: () {
                    return controller.acceptFriendRequest(relationship);
                  },
                  successMessage: 'Friend request accepted',
                ),

                const SizedBox(width: 8),

                _FriendshipActionButton(
                  label: 'Reject',
                  icon: Icons.close,
                  outlined: true,
                  onTap: () {
                    return controller.rejectFriendRequest(relationship);
                  },
                  successMessage: 'Friend request rejected',
                ),
              ],
            );

          // Already friends.
          case RelationshipStatus.accepted:
            return const _FriendsButton();

          // Previous request was rejected.
          case RelationshipStatus.rejected:
            return _FriendshipActionButton(
              label: 'Add Friend',
              icon: Icons.person_add_outlined,
              onTap: () {
                return controller.sendFriendRequest(user);
              },
              successMessage: 'Friend request sent',
            );
        }
      },
    );
  }
}

class _FriendshipActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Future<void> Function() onTap;
  final String successMessage;
  final bool outlined;

  const _FriendshipActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.successMessage,
    this.outlined = false,
  });

  @override
  State<_FriendshipActionButton> createState() =>
      _FriendshipActionButtonState();
}

class _FriendshipActionButtonState extends State<_FriendshipActionButton> {
  bool _isProcessing = false;

  Future<void> _handleTap() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await widget.onTap();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.successMessage)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _isProcessing
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          );

    if (widget.outlined) {
      return OutlinedButton(
        onPressed: _isProcessing ? null : _handleTap,
        child: child,
      );
    }

    return FilledButton(
      onPressed: _isProcessing ? null : _handleTap,
      child: child,
    );
  }
}

class _FriendsButton extends StatelessWidget {
  const _FriendsButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: const Icon(Icons.people_alt_outlined),
      label: const Text('Friends'),
    );
  }
}
