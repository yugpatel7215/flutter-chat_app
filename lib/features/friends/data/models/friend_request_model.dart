import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/data/models/relationship_model.dart';

class FriendRequestModel {
  final UserModel user;
  final RelationshipModel relationship;

  FriendRequestModel({required this.user, required this.relationship});
}
