class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String photoUrl;
  final String about;
  final bool isOnline;
  final DateTime lastSeen;

  const UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.about,
    required this.isOnline,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'about': about,
      'onlineStatus': isOnline,
      'lastSeen': lastSeen,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      about: map['about'] ?? '',
      isOnline: map['onlineStatus'] ?? false,
      lastSeen: map['lastSeen']?.toDate() ?? DateTime.now(),
    );
  }
}
