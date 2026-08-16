import 'dart:async';

import 'package:chat_app/core/navigation/app_route.dart';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_page.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_actions_sheet.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_list_view.dart';
import 'package:chat_app/features/chat/presentation/widgets/friend_shortcut.dart';
import 'package:chat_app/features/chat/presentation/widgets/home_app_bar.dart';
import 'package:chat_app/features/chat/presentation/widgets/home_seach_bar.dart';
import 'package:chat_app/features/chat/presentation/widgets/search_result_view.dart';
import 'package:chat_app/features/chat/providers/chat_provider.dart';
import 'package:chat_app/features/friends/presentation/screens/friend_request_page.dart';
import 'package:chat_app/features/friends/presentation/screens/friends_page.dart';
import 'package:chat_app/features/friends/presentation/user_profile_page.dart';
import 'package:chat_app/features/profile/presentation/screens/my_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isSigningOut = false;

  final _searchController = TextEditingController();

  String _query = '';

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      setState(() {
        _query = value.trim();
      });
    });
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    await Future.wait([
      ref.read(authControllerProvider.notifier).signOut(),
      Future.delayed(const Duration(seconds: 1)),
    ]);

    if (mounted) {
      setState(() {
        _isSigningOut = false;
      });
    }
  }

  void _openFriends() {
    Navigator.push(context, AppRoute.fade(const FriendsPage()));
  }

  void _openFriendRequests() {
    Navigator.push(context, AppRoute.fade(const FriendRequestPage()));
  }

  void _openChat(chat) {
    Navigator.push(context, AppRoute.fade(ChatPage(chat: chat)));
  }

  void _openProfile(user) {
    Navigator.push(context, AppRoute.fade(UserProfilePage(userModel: user)));
  }

  void _openMyProfile() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    Navigator.push(context, AppRoute.fade(MyProfilePage(uid: currentUser.uid)));
  }

  Future<void> _showDeleteConfirmation(ChatTileModel chat) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chat?'),
          content: const Text(
            'This will remove the chat from your chat list. '
            'Your messages will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await ref.read(chatControllerProvider.notifier).deleteChat(chat.chatId);
  }

  void _showChatActions(ChatTileModel chat) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ChatActionsSheet(
          chat: chat,
          onEditDisplayName: () {
            _showEditDisplayNameDialog(chat);
          },
          onDeleteChat: () {
            _showDeleteConfirmation(chat);
          },
        );
      },
    );
  }

  void _showEditDisplayNameDialog(ChatTileModel chat) {
    final controller = TextEditingController(text: chat.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Display Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter display name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nickname = controller.text.trim();

                if (nickname.isEmpty) {
                  return;
                }

                await ref
                    .read(authControllerProvider.notifier)
                    .setNicknames(chat.uid, nickname);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(getChats);

    Theme.of(context);

    return Scaffold(
      appBar: HomeAppBar(
        onProfileTap: _openMyProfile,
        onFriendRequestsTap: _openFriendRequests,
        onSignOut: _signOut,
        isSigningOut: _isSigningOut,
      ),

      body: Column(
        children: [
          // Search section
          HomeSearchBar(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
              _onSearchChanged(value);
            },
            onClear: () {
              _searchController.clear();
              _debounce?.cancel();

              setState(() {
                _query = '';
              });
            },
          ),
          // Friends shortcut
          FriendsShortcut(onTap: _openFriends),

          const SizedBox(height: 4),

          // Main content
          Expanded(
            child: _query.isEmpty
                ? ChatListView(
                    chatsAsync: chatsAsync,
                    onChatTap: _openChat,
                    onChatLongPress: _showChatActions,
                    onRetry: () => ref.invalidate(getChats),
                  )
                : SearchResultsView(query: _query, onUserTap: _openProfile),
          ),
        ],
      ),
    );
  }
}
