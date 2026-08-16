import 'package:chat_app/features/chat/presentation/widgets/home_error_view.dart';
import 'package:chat_app/features/chat/presentation/widgets/no_user_found.dart';
import 'package:chat_app/features/chat/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResultsView extends ConsumerWidget {
  final String query;
  final ValueChanged<dynamic> onUserTap;

  const SearchResultsView({
    super.key,
    required this.query,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchProvider(query));

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
              onTap: () => onUserTap(user),
              leading: CircleAvatar(
                radius: 28,
                foregroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : null,
                child: user.photoUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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

      error: (error, stackTrace) {
        return HomeErrorView(
          message: 'Could not search users.',
          onRetry: () {
            ref.invalidate(searchProvider(query));
          },
        );
      },

      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
