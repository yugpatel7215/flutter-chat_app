import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_input.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_list.dart';
import 'package:chat_app/features/chat/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerStatefulWidget {
  final ChatTileModel chat;

  const ChatPage({super.key, required this.chat});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  MessageModel? _editingMessage;

  void _startEditing(MessageModel message) {
    setState(() {
      _editingMessage = message;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;

    final messageAsync = ref.watch(getMessege(chat.chatId));

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User is not authenticated.')),
      );
    }

    final currentUserId = currentUser.uid;

    final controller = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            radius: 25,
            foregroundImage: chat.photoUrl != null
                ? NetworkImage(chat.photoUrl!)
                : null,
            child: chat.photoUrl == null ? const Icon(Icons.person) : null,
          ),
        ),
        title: Text(chat.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: messageAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return MessageList(
                  messages: messages,
                  currentUserId: currentUserId,
                  onEdit: _startEditing,
                  onDelete: (message) {
                    controller.deleteMessage(message);
                  },
                );
              },
              error: (error, stack) {
                return Center(child: Text('Error occured  :$error'));
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          MessageInput(
            editingMessage: _editingMessage,
            onCancelEdit: _cancelEditing,

            onSend: (text) {
              controller.sendMessage(chat.uid, text);
            },

            // Edited message.
            onEdit: (newText) async {
              final message = _editingMessage;

              if (message == null) {
                return;
              }

              await controller.editMessage(message, newText);

              if (mounted) {
                setState(() {
                  _editingMessage = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
