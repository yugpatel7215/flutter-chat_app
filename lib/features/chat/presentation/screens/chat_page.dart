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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasPhoto = chat.photoUrl != null && chat.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,

        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),

        title: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundImage: hasPhoto ? NetworkImage(chat.photoUrl!) : null,
              child: !hasPhoto
                  ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                  : null,
            ),

            const SizedBox(width: 12),

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
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Container(
              color: colorScheme.surface,
              child: messageAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return _EmptyChatView(userName: chat.name);
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
                  return _ChatErrorView(
                    onRetry: () {
                      ref.invalidate(getMessege(chat.chatId));
                    },
                  );
                },

                loading: () {
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),

          // Message input
          Material(
            elevation: 4,
            color: colorScheme.surface,
            child: MessageInput(
              editingMessage: _editingMessage,
              onCancelEdit: _cancelEditing,

              onSend: (text) {
                controller.sendMessage(chat.uid, text);
              },

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
          ),
        ],
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  final String userName;

  const _EmptyChatView({required this.userName});

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
              Icons.chat_bubble_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),

            const SizedBox(height: 20),

            Text(
              'Start a conversation',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Send a message to $userName and start chatting.',
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

class _ChatErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ChatErrorView({required this.onRetry});

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
              'Could not load messages',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Something went wrong while loading this conversation.',
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
