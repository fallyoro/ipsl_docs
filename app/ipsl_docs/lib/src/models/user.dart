class User {
  final String id;
  final String userName;
  final String email;
  final String classe;
  final int numberContribution;
  String? pictureUrl;
  final bool canUpload;

  User({
    required this.id,
    required this.userName,
    required this.email,
    required this.classe,
    required this.numberContribution,
    this.pictureUrl,
    required this.canUpload,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      userName: json['user_name'] as String,
      email: json['email'] as String,
      classe: json['classe'],
      numberContribution: json['number_contribution'],
      pictureUrl: json['picture_url'],
      canUpload: json['can_upload'] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'email': email,
      'classe': classe,
      'number_contribution': numberContribution,
      'picture_url': pictureUrl,
      'can_upload': canUpload == true ? 1 : 0,
    };
  }

  User copyWith({String? userName, String? classe, bool? canUpload}) {
    return User(
      id: id,
      userName: userName ?? this.userName,
      email: email,
      classe: classe ?? this.classe,
      numberContribution: numberContribution,
      pictureUrl: pictureUrl,
      canUpload: canUpload ?? this.canUpload,
    );
  }
}
