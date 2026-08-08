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

    return relationshipAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      data: (relationship) {
        if (relationship == null) {
          return _AddFriendButton(
            onTap: () => controller.sendFriendRequest(user),
          );
        }

        switch (relationship.status) {
          case RelationshipStatus.pending:
            if (relationship.senderId == currentUser!.uid) {
              return _CancelRequestButton(
                onTap: () => controller.cancelFriendRequest(relationship),
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AcceptFriendButton(
                  onTap: () => controller.acceptFriendRequest(relationship),
                ),
                const SizedBox(width: 8),
                _RejectFriendButton(
                  onTap: () => controller.rejectFriendRequest(relationship),
                ),
              ],
            );

          case RelationshipStatus.accepted:
            return const _FriendsButton();

          case RelationshipStatus.rejected:
            return _AddFriendButton(
              onTap: () => controller.sendFriendRequest(user),
            );
        }
      },
    );
  }
}

class _AddFriendButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddFriendButton({required this.onTap});

  @override
  State<_AddFriendButton> createState() => _AddFriendButtonState();
}

class _AddFriendButtonState extends State<_AddFriendButton> {
  bool _isSending = false;

  Future<void> _handleTap() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      widget.onTap();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend request sent')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSending ? null : _handleTap,
      child: _isSending
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Add Friend'),
    );
  }
}

class _CancelRequestButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CancelRequestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: const Text('Cancel Request'),
    );
  }
}

class _AcceptFriendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AcceptFriendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onTap, child: const Text('Accept'));
  }
}

class _RejectFriendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RejectFriendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onTap, child: const Text('Reject'));
  }
}

class _FriendsButton extends StatelessWidget {
  const _FriendsButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.check, size: 18),
      label: const Text('Friends'),
    );
  }
}
