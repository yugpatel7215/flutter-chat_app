import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(getFriends);

    return Scaffold(
      appBar: AppBar(title: const Text('Friends'), centerTitle: true),
      body: provider.when(
        data: (friends) {
          if (friends.isEmpty) {
            return const Center(child: Text('No friends yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: friends.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final friendsData = friends[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundImage: NetworkImage(friendsData.photoUrl),
                ),
                title: Text(
                  friendsData.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  friendsData.username,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  onPressed: () {
                    _showRemoveFriendDialog(context, friendsData.name, () {
                      ref
                          .read(relationshipControllerProvider.notifier)
                          .removeFriend(friendsData);
                    });
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              );
            },
          );
        },
        error: (error, stack) =>
            Center(child: Text('No friends\n${error.toString()}')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

void _showRemoveFriendDialog(
  BuildContext context,
  String friendName,
  VoidCallback removeFriend,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove $friendName from your friends list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              removeFriend();
              Navigator.pop(context);
            },
            child: const Text(
              'Remove Friend',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
