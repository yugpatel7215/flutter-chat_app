class ChatTileModel {
  final String chatId;
  final String uid;
  final String name;
  final String? photoUrl;
  final String lastMessage;
  final DateTime lastMessageTime;

  const ChatTileModel({
    required this.chatId,
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  ChatTileModel copyWith({
    String? chatId,
    String? uid,
    String? name,
    String? photoUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return ChatTileModel(
      chatId: chatId ?? this.chatId,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }
}
