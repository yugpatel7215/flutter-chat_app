import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_input.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_list.dart';
import 'package:chat_app/features/chat/providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  final ChatTileModel chat;

  const ChatPage({super.key, required this.chat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageAsync = ref.watch(getMessege(chat.chatId));

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User is not authenticated.')),
      );
    }

    final currentUserId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
                );
              },

              error: (error, stack) {
                return Center(child: Text(error.toString()));
              },

              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),

          MessageInput(
            onSend: (text) {
              ref
                  .read(chatControllerProvider.notifier)
                  .sendMessage(chat.uid, text);
            },
          ),
        ],
      ),
    );
  }
}
