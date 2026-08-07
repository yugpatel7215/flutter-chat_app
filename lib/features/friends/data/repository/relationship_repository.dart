import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/data/models/friend_request_model.dart';
import 'package:chat_app/features/friends/data/models/relationship_model.dart';

abstract class FriendRepository {
  // Send a friend request
  Future<void> sendFriendRequest(UserModel receiver);

  // Cancel a pending request
  Future<void> cancelFriendRequest(RelationshipModel relationship);

  // Accept an incoming request
  Future<void> acceptFriendRequest(RelationshipModel relationship);

  // Reject an incoming request
  Future<void> rejectFriendRequest(RelationshipModel relationship);

  // remove friend

  Future<void> removeFriend(RelationshipModel relationship);

  // Get relationship between current user and another user
  Stream<RelationshipModel?> getRelationship(String otherUserId);

  // Incoming requests
  Stream<List<FriendRequestModel>> getIncomingRequests();

  // Outgoing requests
  Stream<List<UserModel>> getOutgoingRequests();

  // Accepted friends
  Stream<List<UserModel>> getFriends();
}
