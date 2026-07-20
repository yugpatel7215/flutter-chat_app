import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/data/repository/firebase_chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchProvider = FutureProvider.family<List<UserModel>, String>((
  ref,
  query,
) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.searchUsers(query);
});

final getMessege = StreamProvider.family<List<MessageModel>, String>((
  ref,
  chatId,
) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getMessages(chatId);
});

final getChats = StreamProvider<List<ChatTileModel>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChats();
});
