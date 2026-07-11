import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        photoUrl: user.photoURL ?? '',
        about: "Hey there! I'm using Chat App.",
        isOnline: true,
        lastSeen: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to create account: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to signed in : $e');
    }
  }

  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastSeen': DateTime.now(),
      });

      await _auth.signOut();
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No authenticated user to verify.');
    }
    try {
      await currentUser!.sendEmailVerification();
    } on FirebaseAuthException {
      rethrow;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to send verification link : $e');
    }
  }

  Future<void> passwordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to send password reset link : $e');
    }
  }

  Future<void> relaodCurrentuser() async {
    final user = currentUser;

    if (user == null) {
      throw Exception('failed to reload');
    }
    await user.reload();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> userChanges() => _auth.userChanges();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});
