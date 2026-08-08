import 'dart:async';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/features/chat/providers/chat_provider.dart';
import 'package:chat_app/features/chat/screens/chat_page.dart';
import 'package:chat_app/features/friends/presentation/screens/friend_request_page.dart';
import 'package:chat_app/features/friends/presentation/screens/friends_page.dart';
import 'package:chat_app/features/friends/presentation/user_profile_page.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      setState(() => _query = value.trim());
    });
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);

    await Future.wait([
      ref.read(authControllerProvider.notifier).signOut(),
      Future.delayed(const Duration(seconds: 1)),
    ]);

    if (mounted) {
      setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(getChats);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: _isSigningOut ? null : _signOut,
              icon: _isSigningOut
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_outlined),
            ),
            const Expanded(child: Center(child: Text('Chats'))),
            Consumer(
              builder: (context, ref, child) {
                final incomingRequestsAsync = ref.watch(getIncomingRequests);
                final requestCount = incomingRequestsAsync.value?.length ?? 0;

                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FriendRequestPage(),
                      ),
                    );
                  },
                  icon: Badge(
                    label: Text('$requestCount'),
                    isLabelVisible: requestCount > 0,
                    child: Icon(Icons.notifications, color: Colors.blue[400]),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FriendsPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.person, size: 35.0),
                Text(
                  'Friends',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Padding(padding: EdgeInsets.only(right: 10)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp('@'))],
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? chatsAsync.when(
                    data: (chats) {
                      if (chats.isEmpty) {
                        return const Center(child: Text('No chats yet'));
                      }
                      return ListView.builder(
                        itemCount: chats.length,
                        itemBuilder: (context, index) {
                          final chatdata = chats[index];
                          final lastMessageTime = DateFormat(
                            'h:mm a',
                          ).format(chatdata.lastMessageTime);
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundImage: chatdata.photoUrl == null
                                    ? null
                                    : NetworkImage(chatdata.photoUrl!),
                                child: chatdata.photoUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(chatdata.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lastMessageTime),
                                  Text(chatdata.lastMessage),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    error: (error, stack) =>
                        Center(child: Text(error.toString())),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  )
                : Consumer(
                    builder: (context, ref, _) {
                      final searchAsync = ref.watch(searchProvider(_query));

                      return searchAsync.when(
                        data: (users) {
                          if (users.isEmpty) {
                            return const Center(child: Text('No users found'));
                          }
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          UserProfilePage(userModel: user),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(user.username),
                                ),
                              );
                            },
                          );
                        },
                        error: (error, stack) =>
                            Center(child: Text(error.toString())),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
