import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/user.dart';

class UserViewModel {
  final SQLiteService _db;

  UserViewModel(this._db);

  void addUser(User user) {
   _db.insertUser(user.toJson());
  }
}
