import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _auth = FirebaseAuth.instance;

final authStateProvider = StreamProvider<User?>((ref) {
  return _auth.userChanges().map((user) {
    // ignore: avoid_print
    print('Provider emitted: ${user?.email}');
    return user;
  });
});
