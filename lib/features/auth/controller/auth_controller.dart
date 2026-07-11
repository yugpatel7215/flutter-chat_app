import 'dart:async';

import 'package:chat_app/features/auth/data/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  FutureOr<void> build() {}

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = await AsyncValue.guard(() async {
      await _repo.signUp(email: email, password: password, name: name);
    });
    await _repo.sendEmailVerification();
  }

  Future<void> sendEmailVerification() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.sendEmailVerification();
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.signIn(email, password);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.signOut();
    });
  }

  Future<void> passwordReset(String email) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repo.passwordReset(email);
    });
  }

  Future<void> reloadCurrentUser() async {
    state = await AsyncValue.guard(() async {
      await _repo.relaodCurrentuser();
    });
  }

  User? get currentUser => _repo.currentUser;
}
