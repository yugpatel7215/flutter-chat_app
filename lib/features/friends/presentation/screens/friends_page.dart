import 'package:chat_app/core/navigation/app_route.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_page.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendsPage extends ConsumerWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(getFriends);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
            return const _EmptyFriendsView();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: friends.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                indent: 88,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outlineVariant,
              );
            },
            itemBuilder: (context, index) {
              final UserModel friend = friends[index];

              return _FriendTile(
                friend: friend,
                onChat: () => _openChat(context, friend),
                onRemove: () {
                  _showRemoveFriendDialog(context, friend.name, () {
                    ref
                        .read(relationshipControllerProvider.notifier)
                        .removeFriend(friend);
                  });
                },
              );
            },
          );
        },
        error: (error, stack) {
          return _FriendsErrorView(
            onRetry: () {
              ref.invalidate(getFriends);
            },
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final UserModel friend;
  final VoidCallback onChat;
  final VoidCallback onRemove;

  const _FriendTile({
    required this.friend,
    required this.onChat,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasPhoto = friend.photoUrl.isNotEmpty;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      leading: CircleAvatar(
        radius: 28,
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundImage: hasPhoto ? NetworkImage(friend.photoUrl) : null,
        child: !hasPhoto
            ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
            : null,
      ),

      title: Text(
        friend.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          friend.username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Message',
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: onChat,
          ),

          PopupMenuButton<String>(
            tooltip: 'Friend options',
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'remove') {
                onRemove();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_remove_outlined,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      const Text('Remove friend'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyFriendsView extends StatelessWidget {
  const _EmptyFriendsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 72,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'No friends yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for people and send them a friend request.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _FriendsErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not load friends',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading your friends.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
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
      final colorScheme = Theme.of(context).colorScheme;

      return AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove '
          '$friendName from your friends list?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              removeFriend();
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      );
    },
  );
}

void _openChat(BuildContext context, UserModel friend) {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return;
  }

  final ids = [currentUser.uid, friend.uid]..sort();

  final chatId = '${ids[0]}_${ids[1]}';

  final chat = ChatTileModel(
    chatId: chatId,
    uid: friend.uid,
    name: friend.name,
    photoUrl: friend.photoUrl,
    lastMessage: '',
    lastMessageTime: DateTime.now(),
  );

  Navigator.push(context, AppRoute.fade(ChatPage(chat: chat)));
}
