import 'package:chat_app/features/chat/data/enum/message_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String messageId;
  final String text;
  final MessageType type;
  final DateTime time;

  const MessageModel({
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.messageId,
    required this.text,
    required this.type,
    required this.time,
  });

  MessageModel copyWith({
    String? chatId,
    String? senderId,
    String? receiverId,
    String? messageId,
    String? text,
    MessageType? type,
    DateTime? time,
  }) {
    return MessageModel(
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageId: messageId ?? this.messageId,
      text: text ?? this.text,
      type: type ?? this.type,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageId': messageId,
      'text': text,
      'type': type.name,
      'time': Timestamp.fromDate(time),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      messageId: map['messageId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values.firstWhere(
        (enumValue) => enumValue.name == map['type'],
      ),
      time: (map['time'] as Timestamp).toDate(),
    );
  }
}
