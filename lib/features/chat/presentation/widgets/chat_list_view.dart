import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_tile.dart';
import 'package:chat_app/features/chat/presentation/widgets/empty_chat_view.dart';
import 'package:chat_app/features/chat/presentation/widgets/home_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatListView extends StatelessWidget {
  final AsyncValue<List<ChatTileModel>> chatsAsync;
  final ValueChanged<ChatTileModel> onChatTap;
  final ValueChanged<ChatTileModel> onChatLongPress;
  final VoidCallback onRetry;

  const ChatListView({
    super.key,
    required this.chatsAsync,
    required this.onChatTap,
    required this.onChatLongPress,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return chatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const EmptyChatsView();
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 4, bottom: 16),
          itemCount: chats.length,
          separatorBuilder: (context, index) {
            return const Divider(height: 1, indent: 88, endIndent: 16);
          },
          itemBuilder: (context, index) {
            final chat = chats[index];

            return ChatTile(
              chat: chat,
              onTap: () => onChatTap(chat),
              onLongPress: () => onChatLongPress(chat),
            );
          },
        );
      },

      error: (error, stackTrace) {
        return HomeErrorView(
          message: 'Could not load your chats.',
          onRetry: onRetry,
        );
      },

      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
