import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/profile/repository/profile_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseProfileRepository extends ProfileRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  FirebaseProfileRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel> getMyProfileData(String uid) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('No Authorized User');
    }

    return _firestore.collection('users').doc(uid).snapshots().asyncMap((
      snapshot,
    ) {
      if (!snapshot.exists) {
        throw Exception('No data found');
      }
      return UserModel.fromMap(snapshot.data()!);
    });
  }

  Future<bool> isUsernameAvailable(String username) async {
    final existingUsers = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return existingUsers.docs.isEmpty;
  }

  Future<UserModel> updateProfile(
    String? uid,
    String? username,
    String? name,
    String? about,
  ) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('No Authorized User');
    }

    final userRef = _firestore.collection('users').doc(uid);

    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      throw Exception('No data found');
    }

    final data = snapshot.data();

    if (data == null) {
      throw Exception('No data found');
    }

    final currentUserModel = UserModel.fromMap(data);

    final updatedData = currentUserModel.copyWith(
      about: about ?? currentUserModel.about,
      name: name ?? currentUserModel.name,
      username: username ?? currentUserModel.username,
    );

    await userRef.update(updatedData.toMap());

    return updatedData;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirebaseProfileRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});
