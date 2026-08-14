class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String photoUrl;
  final String about;
  final bool isOnline;
  final DateTime lastSeen;
  final Map<String, String> nicknames;

  const UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.about,
    required this.isOnline,
    required this.lastSeen,
    required this.nicknames,
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
      'nicknames': nicknames,
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
      nicknames: Map<String, String>.from(map['nicknames'] ?? {}),
    );
  }

  UserModel copyWith({
    String? username,
    String? name,
    String? about,
    Map<String, String>? nicknames,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email,
      photoUrl: photoUrl,
      about: about ?? this.about,
      isOnline: isOnline,
      lastSeen: lastSeen,
      nicknames: nicknames ?? this.nicknames,
    );
  }
}
