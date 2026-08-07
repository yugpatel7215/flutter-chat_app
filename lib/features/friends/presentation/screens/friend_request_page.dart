import 'package:chat_app/features/friends/presentation/widgets/friend_request_tile.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestPage extends ConsumerStatefulWidget {
  const FriendRequestPage({super.key});

  @override
  ConsumerState<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends ConsumerState<FriendRequestPage> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(getIncomingRequests);

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: provider.when(
        data: (data) {
          return data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_disabled,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No friend requests',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final request = data[index];
                    return FriendRequestTile(request: request);
                  },
                );
        },
        error: (error, stack) =>
            Center(child: Text('Error occured ${error.toString()}')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
