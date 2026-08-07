import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/presentation/widgets/friendship_section.dart';
import 'package:chat_app/features/friends/presentation/widgets/profile_header.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final UserModel userModel;
  const UserProfilePage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeader(userModel: userModel),
          SizedBox(height: 10),
          FriendshipSection(user: userModel),
        ],
      ),
    );
  }
}
