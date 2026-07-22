import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/data/models/relationship_model.dart';

abstract class FriendRepository {
  // Send a friend request
  Future<void> sendFriendRequest(UserModel receiver);

  // Cancel a pending request
  Future<void> cancelFriendRequest(RelationshipModel relationship);

  // Accept an incoming request
  Future<void> acceptFriendRequest(String receiverId);

  // Reject an incoming request
  Future<void> rejectFriendRequest(RelationshipModel relationship);

  // remove friend

  Future<void> removeFriend(RelationshipModel relationship);

  // Get relationship between current user and another user
  Stream<RelationshipModel?> getRelationship(String otherUserId);

  // Incoming requests
  Stream<List<RelationshipModel>> getIncomingRequests();

  // Outgoing requests
  Stream<List<RelationshipModel>> getOutgoingRequests();

  // Accepted friends
  Stream<List<RelationshipModel>> getFriends();
}
