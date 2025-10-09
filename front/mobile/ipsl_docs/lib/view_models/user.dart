import 'package:flutter/widgets.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/user.dart';

class UserViewModel {
  final DatabaseHelper _db;
  ValueNotifier<User?> userNotifier = ValueNotifier(null);

  UserViewModel(this._db);
  Future<void> addUser(User user) async {
    await _db.insertUser(user);
    userNotifier.value = user;
  }

  Future<void> updateUser(String userName, String classe) async {
    await _db.updateUser(classe, userName);
    userNotifier.value = await getUser();
  }

  Future<void> updateNumberContribution(int numberContribution) async {
    await _db.updateNumberContribution(numberContribution);
    await init();
  }

  Future<void> init() async {
    final User? user = await getUser();
    if (user != null) {
      userNotifier.value = user;
    } else {
      // Gérer le cas où l'utilisateur est null
      userNotifier.value = User(
        id: "23",
        classe: "N/A",
        numberContribution: 000,
        userName: "N/A",
      ); // Exemple : initialiser avec un utilisateur vide
    }
  }

  Future<User?> getUser() async {
    final User? user = await _db.getUser();
    if (user != null) {
      user.toString();
      // userNotifier.value = user;
    }

    return user;
    //WidgetsBinding.instance.addPostFrameCallback((_) {
    //userNotifier.value = user;
    //});
  }
}
