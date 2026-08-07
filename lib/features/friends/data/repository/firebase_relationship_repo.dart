import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/friends/data/enum/friendship_enum.dart';
import 'package:chat_app/features/friends/data/models/friend_request_model.dart';
import 'package:chat_app/features/friends/data/models/relationship_model.dart';
import 'package:chat_app/features/friends/data/repository/relationship_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseFriendRepository implements FriendRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseFriendRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String _generateRelationshipId(String uid1, String uid2) {
    final List<String> ids = [uid1, uid2];
    ids.sort();
    final relationshipId = '${ids[0]}_${ids[1]}';
    return relationshipId;
  }

  @override
  Future<void> sendFriendRequest(UserModel receiver) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return;
    }

    await _firestore.runTransaction((transaction) async {
      final relationshipId = _generateRelationshipId(
        currentUser.uid,
        receiver.uid,
      );

      final relationshipDoc = _firestore
          .collection('relationships')
          .doc(relationshipId);

      final snapshot = await transaction.get(relationshipDoc);

      // First request → create relationship and stop.
      if (!snapshot.exists) {
        final relationship = RelationshipModel(
          participants: [currentUser.uid, receiver.uid],
          senderId: currentUser.uid,
          receiverId: receiver.uid,
          status: RelationshipStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        transaction.set(relationshipDoc, relationship.toMap());

        return;
      }

      // Relationship already exists.
      final relationship = RelationshipModel.fromMap(snapshot.data()!);

      switch (relationship.status) {
        case RelationshipStatus.pending:
          return;

        case RelationshipStatus.accepted:
          return;

        case RelationshipStatus.rejected:
          final currentTime = DateTime.now();
          const cooldown = Duration(days: 1);

          if (currentTime.difference(relationship.updatedAt) >= cooldown) {
            transaction.update(
              relationshipDoc,
              relationship
                  .copyWith(
                    status: RelationshipStatus.pending,
                    updatedAt: currentTime,
                  )
                  .toMap(),
            );
          }

          return;
      }
    });
  }

  @override
  Future<void> acceptFriendRequest(RelationshipModel relationship) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('No authenticated user.');
    }
    final relationshId = _generateRelationshipId(
      currentUser.uid,
      relationship.senderId,
    );

    final relationshipDoc = _firestore
        .collection('relationships')
        .doc(relationshId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(relationshipDoc);

      if (!snapshot.exists) {
        throw StateError('Relationship does not exist.');
      }

      final relationship = RelationshipModel.fromMap(snapshot.data()!);

      // Only the receiver can accept the request.
      if (currentUser.uid != relationship.receiverId) {
        throw StateError('Only the receiver can accept this request.');
      }

      switch (relationship.status) {
        case RelationshipStatus.pending:
          final currentTime = DateTime.now();

          final updatedRelationship = relationship.copyWith(
            status: RelationshipStatus.accepted,
            updatedAt: currentTime,
          );

          transaction.set(relationshipDoc, updatedRelationship.toMap());
          return;

        case RelationshipStatus.accepted:
          return;

        case RelationshipStatus.rejected:
          return;
      }
    });
  }

  @override
  Future<void> cancelFriendRequest(RelationshipModel relationship) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('No authenticated user.');
    }

    final relationshipId = _generateRelationshipId(
      currentUser.uid,
      relationship.receiverId,
    );

    await _firestore.runTransaction((transaction) async {
      final relationshipDoc = _firestore
          .collection('relationships')
          .doc(relationshipId);

      final snapshot = await transaction.get(relationshipDoc);

      if (!snapshot.exists) {
        throw StateError('No relationship exist');
      }
      final current = RelationshipModel.fromMap(snapshot.data()!);

      if (currentUser.uid != current.senderId) {
        throw StateError('Only the sender can cancel the request');
      }
      switch (current.status) {
        case RelationshipStatus.pending:
          transaction.delete(relationshipDoc);
          break;
        case RelationshipStatus.accepted:
          throw StateError('Cannot cancel an already-accepted request.');
        case RelationshipStatus.rejected:
          throw StateError('Cannot cancel a rejected request.');
      }
    });
  }

  @override
  Future<void> removeFriend(RelationshipModel relationship) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('No authenticated user.');
    }

    final otherPersonId = relationship.participants.firstWhere(
      (id) => id != currentUser.uid,
    );

    final relationshipId = _generateRelationshipId(
      currentUser.uid,
      otherPersonId,
    );

    await _firestore.runTransaction((transaction) async {
      final relationshipDoc = _firestore
          .collection('relationships')
          .doc(relationshipId);

      final snapshot = await transaction.get(relationshipDoc);

      if (!snapshot.exists) {
        throw StateError('No relationship exist');
      }
      final current = RelationshipModel.fromMap(snapshot.data()!);

      if (!current.participants.contains(currentUser.uid)) {
        throw StateError('You are not part of this relationship.');
      }

      switch (current.status) {
        case RelationshipStatus.pending:
          return;
        case RelationshipStatus.rejected:
          return;
        case RelationshipStatus.accepted:
          transaction.delete(relationshipDoc);
      }
    });
  }

  @override
  @override
  Stream<List<UserModel>> getFriends() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }

    return _firestore
        .collection('relationships')
        .where('participants', arrayContains: currentUser.uid)
        .where('status', isEqualTo: RelationshipStatus.accepted.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RelationshipModel.fromMap(doc.data()))
              .toList(),
        )
        .asyncMap((relationships) async {
          if (relationships.isEmpty) {
            return <UserModel>[];
          }

          final friendIds = relationships
              .map(
                (relationship) => relationship.participants.firstWhere(
                  (uid) => uid != currentUser.uid,
                ),
              )
              .toSet()
              .toList();

          final usersSnapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: friendIds)
              .get();

          final users = usersSnapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();

          // Preserve the original relationship order.
          final userMap = {for (final user in users) user.uid: user};

          return friendIds
              .map((id) => userMap[id])
              .whereType<UserModel>()
              .toList();
        });
  }

  @override
  Future<void> rejectFriendRequest(RelationshipModel relationship) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('No authenticated user.');
    }

    final relationshipId = _generateRelationshipId(
      currentUser.uid,
      relationship.senderId,
    );

    await _firestore.runTransaction((transaction) async {
      final relationshipDoc = _firestore
          .collection('relationships')
          .doc(relationshipId);
      final snapshot = await transaction.get(relationshipDoc);

      if (!snapshot.exists) {
        throw StateError('No relationship exist');
      }
      final current = RelationshipModel.fromMap(snapshot.data()!);

      if (currentUser.uid != current.receiverId) {
        throw StateError('Only the receiver can reject the request');
      }

      switch (current.status) {
        case RelationshipStatus.pending:
          final updatedRelationship = current.copyWith(
            status: RelationshipStatus.rejected,
            updatedAt: DateTime.now(),
          );
          transaction.set(relationshipDoc, updatedRelationship.toMap());
          break;
        case RelationshipStatus.rejected:
          return;
        case RelationshipStatus.accepted:
          return;
      }
    });
  }

  @override
  @override
  Stream<List<FriendRequestModel>> getIncomingRequests() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }

    return _firestore
        .collection('relationships')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: RelationshipStatus.pending.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RelationshipModel.fromMap(doc.data()))
              .toList(),
        )
        .asyncMap((relationships) async {
          if (relationships.isEmpty) {
            return <FriendRequestModel>[];
          }

          final senderIds = relationships
              .map((relationship) => relationship.senderId)
              .toSet()
              .toList();

          final usersSnapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: senderIds)
              .get();

          final users = usersSnapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();

          final userMap = {for (final user in users) user.uid: user};

          return relationships
              .map((relationship) {
                final sender = userMap[relationship.senderId];
                if (sender == null) return null;
                return FriendRequestModel(
                  relationship: relationship,
                  user: sender,
                );
              })
              .whereType<FriendRequestModel>()
              .toList();
        });
  }

  @override
  Stream<List<UserModel>> getOutgoingRequests() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }

    return _firestore
        .collection('relationships')
        .where('senderId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: RelationshipStatus.pending.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => RelationshipModel.fromMap(doc.data()))
              .toList(),
        )
        .asyncMap((relationships) async {
          if (relationships.isEmpty) return <UserModel>[];

          final receiverIds = relationships
              .map((r) => r.receiverId)
              .toSet()
              .toList();

          final usersSnapshot = await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: receiverIds)
              .get();

          final users = usersSnapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();

          final userMap = {for (final user in users) user.uid: user};

          return receiverIds
              .map((id) => userMap[id])
              .whereType<UserModel>()
              .toList();
        });
  }

  @override
  @override
  Stream<RelationshipModel?> getRelationship(String otherUserId) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }

    final relationshipId = _generateRelationshipId(
      currentUser.uid,
      otherUserId,
    );

    return _firestore
        .collection('relationships')
        .doc(relationshipId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }

          return RelationshipModel.fromMap(snapshot.data()!);
        });
  }
}

final relationshipRepositoryProvider = Provider<FirebaseFriendRepository>((
  ref,
) {
  return FirebaseFriendRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});
