import 'dart:async';

import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/profile/repository/firebase_profile_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends AsyncNotifier {
  late final _repo;
  @override
  FutureOr<void> build() {
    _repo = ref.watch(profileRepositoryProvider);
  }

  Stream<UserModel> getMyProfileData(String uid) {
    return _repo.getMyProfileData(uid);
  }

  Future<bool> isUsernameAvailable(String username) async {
    return await _repo.isUsernameAvailable(username);
  }

  Future<void> updateProfile(
    String? uid,
    String? username,
    String? name,
    String? about,
  ) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repo.updateProfile(uid, username, name, about);
    });
  }
}
