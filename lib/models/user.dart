
class User {
  final int id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ?? 0,
      username: json['username'] ?? 'Unknown',
      email: json['email'] ?? 'No Email',
    );
  }
}