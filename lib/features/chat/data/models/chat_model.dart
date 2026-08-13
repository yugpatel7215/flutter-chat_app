import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageId;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> deletedFor;

  const ChatModel({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageId,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedFor,
  });

  ChatModel copyWith({
    String? chatId,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageId,
    String? lastMessageSenderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? deletedFor,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedFor: deletedFor ?? this.deletedFor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageId': lastMessageId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedFor': deletedFor,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageId: map['lastMessageId'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      deletedFor: List<String>.from(map['deletedFor'] ?? []),
    );
  }
}
