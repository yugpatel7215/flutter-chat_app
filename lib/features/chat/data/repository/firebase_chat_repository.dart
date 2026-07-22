import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/chat/data/enum/message_enum.dart';
import 'package:chat_app/features/chat/data/models/chat_model.dart';
import 'package:chat_app/features/chat/data/models/chattile_model.dart';
import 'package:chat_app/features/chat/data/models/message_model.dart';
import 'package:chat_app/features/chat/data/repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseChatRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Stream<List<ChatTileModel>> getChats() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(<ChatTileModel>[]);
    }

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
          final tiles = await Future.wait(
            snapshot.docs.map((documents) async {
              try {
                final chatModel = ChatModel.fromMap(
                  documents.data() as Map<String, dynamic>,
                );

                final otherPersonUid = chatModel.participants.firstWhere(
                  (uid) => uid != currentUser.uid,
                );

                final userDoc = await _firestore
                    .collection('users')
                    .doc(otherPersonUid)
                    .get();

                final otherPersonData = userDoc.data();

                if (!userDoc.exists || otherPersonData == null) {
                  return null;
                }

                final otherUser = UserModel.fromMap(otherPersonData);

                return ChatTileModel(
                  chatId: chatModel.chatId,
                  uid: otherUser.uid,
                  name: otherUser.name,
                  lastMessage: chatModel.lastMessage,
                  lastMessageTime: chatModel.lastMessageTime,
                );
              } catch (e) {
                return null;
              }
            }),
          );

          return tiles.whereType<ChatTileModel>().toList();
        });
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time')
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs.map((messages) {
            return MessageModel.fromMap(
              messages.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  @override
  Future<UserModel?> getUserById(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();

    final userData = userDoc.data();
    if (userData == null) {
      return null;
    }

    return UserModel.fromMap(userData);
  }

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final lowerQuery = query.toLowerCase();
    final searchTerm = '@$lowerQuery';

    print('Searching for: "$searchTerm" to "$searchTerm\uf8ff"');

    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchTerm)
        .where('username', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();

    print('Docs found: ${querySnapshot.docs.length}');

    final users = querySnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .where((user) => user.uid != currentUser.uid)
        .toList();

    return users;
  }

  @override
  @override
  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('No authenticated user found.');
    }

    final currentUserId = currentUser.uid;

    // Generate deterministic chatId
    final ids = [currentUserId, receiverId]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    // Generate messageId
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final messageId = messageRef.id;

    // Create MessageModel
    final messageModel = MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      type: MessageType.text,
      time: DateTime.now(),
    );

    // Chat document reference
    final chatRef = _firestore.collection('chats').doc(chatId);

    // Read chat document
    final chatSnapshot = await chatRef.get();

    // Create batch
    final batch = _firestore.batch();

    if (!chatSnapshot.exists) {
      // Create ChatModel only for a new chat
      final chatModel = ChatModel(
        chatId: chatId,
        participants: ids,
        lastMessage: text,
        lastMessageTime: messageModel.time,
        lastMessageSenderId: currentUserId,
        createdAt: messageModel.time,
        updatedAt: messageModel.time,
      );

      batch.set(chatRef, chatModel.toMap());
    } else {
      // Existing chat → update only changed fields
      batch.update(chatRef, {
        'lastMessage': text,
        'lastMessageTime': messageModel.time,
        'lastMessageSenderId': currentUserId,
        'updatedAt': messageModel.time,
      });
    }

    // Add the message document
    batch.set(messageRef, messageModel.toMap());

    // Commit everything atomically
    await batch.commit();
  }
}

final chatRepositoryProvider = Provider((ref) {
  return FirebaseChatRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});
