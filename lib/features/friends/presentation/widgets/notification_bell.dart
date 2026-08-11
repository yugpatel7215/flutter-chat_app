import 'package:flutter/material.dart';

class NotificationBell extends StatefulWidget {
  final int count;
  final VoidCallback onTap;

  const NotificationBell({super.key, required this.count, required this.onTap});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  int _previousCount = 0;

  @override
  void initState() {
    super.initState();

    _previousCount = widget.count;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween<double>(
      begin: 1,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant NotificationBell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.count > _previousCount) {
      _controller.forward(from: 0).then((_) {
        if (mounted) {
          _controller.reverse();
        }
      });
    }

    _previousCount = widget.count;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        tooltip: 'Friend requests',
        onPressed: widget.onTap,
        icon: Badge(
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          label: Text('${widget.count}'),
          child: Icon(Icons.notifications_outlined, color: colorScheme.primary),
        ),
      ),
    );
  }
}
