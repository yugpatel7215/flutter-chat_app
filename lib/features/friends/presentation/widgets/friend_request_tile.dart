import 'package:chat_app/features/friends/data/models/friend_request_model.dart';
import 'package:chat_app/features/friends/providers/relationship_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FriendRequestTile extends ConsumerStatefulWidget {
  final FriendRequestModel request;

  const FriendRequestTile({super.key, required this.request});

  @override
  ConsumerState<FriendRequestTile> createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends ConsumerState<FriendRequestTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _opacity = Tween<double>(begin: 1, end: 0).animate(animation);

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.15, 0),
    ).animate(animation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Start the visual exit immediately.
      final animationFuture = _controller.forward();

      // Run the actual Firestore operation at the same time.
      await Future.wait([animationFuture, action()]);
    } catch (_) {
      // If the operation fails, restore the tile.
      if (mounted) {
        await _controller.reverse();

        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.request.user;
    final relationship = widget.request.relationship;

    final controller = ref.read(relationshipControllerProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),

            // Profile image
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
                  : null,
            ),

            // Name
            title: Text(
              user.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            // About
            subtitle: Text(
              user.about.trim().isEmpty
                  ? 'Wants to connect with you'
                  : user.about,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            // Actions
            trailing: _isProcessing
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Accept',
                        onPressed: () {
                          _handleAction(
                            () => controller.acceptFriendRequest(relationship),
                          );
                        },
                        icon: const Icon(Icons.check, size: 20),
                      ),

                      const SizedBox(width: 4),

                      IconButton(
                        tooltip: 'Reject',
                        onPressed: () {
                          _handleAction(
                            () => controller.rejectFriendRequest(relationship),
                          );
                        },
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
