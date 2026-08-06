import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _auth = FirebaseAuth.instance;

final authStateProvider = StreamProvider<User?>((ref) {
  return _auth.userChanges().map((user) {
    return user;
  });
});

final viewedUserProvider = StreamProvider.family<UserModel?, String>((
  ref,
  uid,
) {
  final controller = ref.watch(authControllerProvider.notifier);
  return controller.getUser(uid);
});
