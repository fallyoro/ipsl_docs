class User {
  final String id;
  final String userName;
  final String classe;
  final int numberContribution;

  User({
    required this.id,
    required this.userName,
    required this.classe,
    required this.numberContribution,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      userName: json['user_name'] as String,

      classe: json['classe'],
      numberContribution: json['number_contribution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'classe': classe,
      'number_contribution': numberContribution,
    };
  }
}
