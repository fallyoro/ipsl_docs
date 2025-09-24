import 'package:flutter/widgets.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/user.dart';

class UserViewModel {
  final DatabaseHelper _db;
  ValueNotifier<User> userNotifier = ValueNotifier(
    User(
      id: "0",
      userName: "userName",
      classe: "classe",
      numberContribution: 10000,
    ),
  );

  UserViewModel(this._db);

  void addUser(User user) {
    _db.insertUser(user);
    userNotifier.value = user;
  }

  Future<void> updateUser(String userName, String classe) async {
    _db.updateUser(classe, userName);
    getUser();
  }

  void updateNumberContribution(int numberContribution) {
    _db.updateNumberContribution(numberContribution);
    getUser();
  }

  Future<void> getUser() async {
    final User user = await _db.getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userNotifier.value = user;
    });
  }
}
