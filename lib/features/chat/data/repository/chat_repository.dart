import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';

abstract class ChatRepository {
  // get chats

  Stream<List<ChatTileModel>> getChats();

  //  get the message
  Stream<List<MessageModel>> getMessages(String chatId);

  // send message
  Future<void> sendMessage({required String text, required String receiverId});

  // seach user
  Future<List<UserModel>> searchUsers(String query);

  //get user

  Future<void> getUserById(String uid);
}
