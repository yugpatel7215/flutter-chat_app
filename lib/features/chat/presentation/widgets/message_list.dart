import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<MessageModel> messages;
  final String currentUserId;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: false,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];

        return MessageBubble(message: message, currentUserId: currentUserId);
      },
    );
  }
}
