import 'package:flutter/widgets.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/user.dart';

class UserViewModel {
  final SQLiteService _db;
  ValueNotifier<User> userNotifier = ValueNotifier(
    User(id: "0", userName: "userName", email: "email"),
  );

  UserViewModel(this._db);

  void addUser(User user) {
    _db.insertUser(user.toJson());
    userNotifier.value = user;
  }

  void getUser() {
    final rawUsers = _db.getUser();

    userNotifier.value = User.fromJson(rawUsers!);
  }
}
