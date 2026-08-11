import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class MessageList extends StatefulWidget {
  final List<MessageModel> messages;
  final String currentUserId;
  final ValueChanged<MessageModel> onEdit;
  final ValueChanged<MessageModel> onDelete;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // New message added.
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      reverse: false,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];

        return MessageBubble(
          message: message,
          currentUserId: widget.currentUserId,
          onDelete: () => widget.onDelete(message),
          onEdit: () => widget.onEdit(message),
        );
      },
    );
  }
}
