import 'package:chat_app/features/friends/data/enum/friendship_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RelationshipModel {
  final List<String> participants;
  final String senderId;
  final String receiverId;
  final RelationshipStatus status;
  final DateTime updatedAt;
  final DateTime createdAt;

  RelationshipModel({
    required this.participants,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
  });

  RelationshipModel copyWith({
    List<String>? participants,
    String? senderId,
    String? receiverId,
    RelationshipStatus? status,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return RelationshipModel(
      participants: participants ?? this.participants,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.name,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RelationshipModel.fromMap(Map<String, dynamic> map) {
    return RelationshipModel(
      participants: List<String>.from(map['participants'] ?? []),
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: RelationshipStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => RelationshipStatus.pending,
      ),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
