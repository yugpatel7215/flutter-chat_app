import 'package:chat_app/features/friends/data/models/friend_request_model.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestTile extends ConsumerWidget {
  final FriendRequestModel request;

  const FriendRequestTile({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = request.user;
    final relationship = request.relationship;
    final controller = ref.read(relationshipControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 24,
          foregroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : null,
          child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(user.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => controller.acceptFriendRequest(relationship),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => controller.rejectFriendRequest(relationship),
            ),
          ],
        ),
      ),
    );
  }
}
