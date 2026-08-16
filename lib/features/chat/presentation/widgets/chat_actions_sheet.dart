import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:flutter/material.dart';

class ChatActionsSheet extends StatelessWidget {
  final ChatTileModel chat;
  final VoidCallback onEditDisplayName;
  final VoidCallback onDeleteChat;

  const ChatActionsSheet({
    super.key,
    required this.chat,
    required this.onEditDisplayName,
    required this.onDeleteChat,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Display Name'),
            onTap: () {
              Navigator.pop(context);
              onEditDisplayName();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Chat'),
            onTap: () {
              Navigator.pop(context);
              onDeleteChat();
            },
          ),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Cancel'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
