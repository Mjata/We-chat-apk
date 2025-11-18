
class User {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String profilePictureUrl;
  final bool isOnline;
  final bool isInCall;

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.profilePictureUrl,
    required this.isOnline,
    required this.isInCall,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'No Name',
      age: json['age'] ?? 0,
      bio: json['bio'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isInCall: json['isInCall'] ?? false,
    );
  }
}
