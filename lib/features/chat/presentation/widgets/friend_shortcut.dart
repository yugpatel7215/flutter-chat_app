import 'package:flutter/material.dart';

class FriendsShortcut extends StatelessWidget {
  final VoidCallback onTap;

  const FriendsShortcut({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.people_outline, size: 20),
          label: const Text('Friends'),
        ),
      ),
    );
  }
}
