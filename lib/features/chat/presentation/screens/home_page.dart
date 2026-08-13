import 'dart:async';

import 'package:chat_app/core/navigation/app_route.dart';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_page.dart';
import 'package:chat_app/features/chat/presentation/widgets/chat_tile.dart';
import 'package:chat_app/features/chat/presentation/widgets/empty_chat_view.dart';
import 'package:chat_app/features/chat/presentation/widgets/home_error_view.dart';
import 'package:chat_app/features/chat/presentation/widgets/no_user_found.dart';
import 'package:chat_app/features/chat/providers/chat_provider.dart';
import 'package:chat_app/features/friends/presentation/screens/friend_request_page.dart';
import 'package:chat_app/features/friends/presentation/screens/friends_page.dart';
import 'package:chat_app/features/friends/presentation/user_profile_page.dart';
import 'package:chat_app/features/friends/presentation/widgets/notification_bell.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:chat_app/features/profile/presentation/widget/animated_profile_photo.dart';
import 'package:chat_app/features/profile/providers/profile_provider.dart';
import 'package:chat_app/features/profile/presentation/screens/my_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Display Name'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: edit display name
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(chat);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(getChats);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Consumer(
          builder: (context, ref, child) {
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser == null) {
              return const Padding(
                padding: EdgeInsets.all(8),
                child: CircleAvatar(child: Icon(Icons.person)),
              );
            }

            final profileAsync = ref.watch(getProfileData(currentUser.uid));

            return profileAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: CircleAvatar(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

              error: (_, __) => Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedProfileAvatar(
                  onTap: _openMyProfile,
                  child: const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person),
                  ),
                ),
              ),

              data: (user) {
                final hasPhoto = user.photoUrl.trim().isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedProfileAvatar(
                    onTap: _openMyProfile,
                    child: CircleAvatar(
                      radius: 20,
                      foregroundImage: hasPhoto
                          ? NetworkImage(user.photoUrl)
                          : null,
                      child: hasPhoto ? null : const Icon(Icons.person),
                    ),
                  ),
                );
              },
            );
          },
        ),
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final incomingRequestsAsync = ref.watch(getIncomingRequests);

              final requestCount = incomingRequestsAsync.value?.length ?? 0;

              return NotificationBell(
                count: requestCount,
                onTap: _openFriendRequests,
              );
            },
          ),

          IconButton(
            tooltip: 'Sign out',
            onPressed: _isSigningOut ? null : _signOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_outlined),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // Search section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp('@'))],
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();

                          setState(() {
                            _query = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
            ),
          ),

          // Friends shortcut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _openFriends,
                icon: const Icon(Icons.people_outline, size: 20),
                label: const Text('Friends'),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Main content
          Expanded(
            child: _query.isEmpty
                ? _buildChats(context, chatsAsync)
                : _buildSearchResults(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChats(BuildContext context, AsyncValue chatsAsync) {
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
              onTap: () => _openChat(chat),
              onLongPress: () => _showChatActions(chat),
            );
          },
        );
      },
      error: (error, stack) {
        return HomeErrorView(
          message: 'Could not load your chats.',
          onRetry: () {
            ref.invalidate(getChats);
          },
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final searchAsync = ref.watch(searchProvider(_query));

        return searchAsync.when(
          data: (users) {
            if (users.isEmpty) {
              return const NoUsersFoundView();
            }

            return ListView.separated(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: users.length,
              separatorBuilder: (context, index) {
                return const Divider(height: 1, indent: 88, endIndent: 16);
              },
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  onTap: () => _openProfile(user),

                  leading: CircleAvatar(
                    radius: 28,
                    foregroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  title: Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  subtitle: Text(
                    user.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  trailing: const Icon(Icons.chevron_right),
                );
              },
            );
          },
          error: (error, stack) {
            return HomeErrorView(
              message: 'Could not search users.',
              onRetry: () {
                ref.invalidate(searchProvider(_query));
              },
            );
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}
