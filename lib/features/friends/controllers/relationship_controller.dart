import 'dart:async';

import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/data/models/friend_request_model.dart';
import 'package:chat_app/features/friends/data/models/relationship_model.dart';
import 'package:chat_app/features/friends/data/repository/firebase_relationship_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RelationshipController extends AsyncNotifier<void> {
  FirebaseFriendRepository get _repo =>
      ref.watch(relationshipRepositoryProvider);
  @override
  FutureOr<void> build() {
    return null;
  }

  Stream<RelationshipModel?> getRelationship(String otherUserId) {
    return _repo.getRelationship(otherUserId);
  }

  Stream<List<UserModel>> getFriends() {
    return _repo.getFriends();
  }

  Stream<List<FriendRequestModel>> getIncomingRequests() {
    return _repo.getIncomingRequests();
  }

  Stream<List<UserModel>> getOutgoingRequests() {
    return _repo.getOutgoingRequests();
  }

  Future<void> sendFriendRequest(UserModel receiver) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.sendFriendRequest(receiver);
    });
  }

  Future<void> cancelFriendRequest(RelationshipModel relationship) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.cancelFriendRequest(relationship);
    });
  }

  Future<void> acceptFriendRequest(RelationshipModel relationship) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.acceptFriendRequest(relationship);
    });
  }

  Future<void> rejectFriendRequest(RelationshipModel relationship) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.rejectFriendRequest(relationship);
    });
  }
}
