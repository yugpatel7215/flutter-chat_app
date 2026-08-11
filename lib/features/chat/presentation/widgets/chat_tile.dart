import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatTile extends StatelessWidget {
  final ChatTileModel chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lastMessageTime = DateFormat('h:mm a').format(chat.lastMessageTime);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      leading: CircleAvatar(
        radius: 28,
        foregroundImage: chat.photoUrl != null && chat.photoUrl!.isNotEmpty
            ? NetworkImage(chat.photoUrl!)
            : null,
        child: chat.photoUrl == null || chat.photoUrl!.isEmpty
            ? const Icon(Icons.person, size: 28)
            : null,
      ),

      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            lastMessageTime,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
