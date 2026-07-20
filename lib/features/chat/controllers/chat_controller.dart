import 'dart:async';

import 'package:chat_app/features/chat/data/repository/firebase_chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatController extends AsyncNotifier<void> {
  late final _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(chatRepositoryProvider);
    return null;
  }

  Future<void> sendMessage(String receiverId, String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.sendMessage(receiverId: receiverId, text: text);
    });
  }

  Future<void> getUserById(String uid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.getUserById(uid);
    });
  }
}
