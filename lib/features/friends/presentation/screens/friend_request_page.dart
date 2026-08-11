import 'package:chat_app/features/friends/presentation/widgets/friend_request_tile.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestPage extends ConsumerWidget {
  const FriendRequestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(getIncomingRequests);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friend Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const _EmptyRequestsView();
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: requests.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 1,
                indent: 88,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outlineVariant,
              );
            },
            itemBuilder: (context, index) {
              return FriendRequestTile(request: requests[index]);
            },
          );
        },
        error: (error, stack) {
          return _RequestsErrorView(
            onRetry: () {
              ref.invalidate(getIncomingRequests);
            },
          );
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _EmptyRequestsView extends StatelessWidget {
  const _EmptyRequestsView();

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
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                Icons.person_add_disabled_outlined,
                size: 52,
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No friend requests',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'When someone sends you a friend request, '
              'it will appear here.',
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

class _RequestsErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _RequestsErrorView({required this.onRetry});

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
              'Could not load requests',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Something went wrong while loading your '
              'friend requests.',
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
