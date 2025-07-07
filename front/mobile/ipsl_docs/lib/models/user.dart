class User {
  final String id;
  final String userName;
  final String email;

  User({required this.id, required this.userName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      userName: json['user_name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_name': userName, 'email': email};
  }
}
