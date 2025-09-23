import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/models/user.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../core/utils.dart';

class DatabaseHelper {
  static Database? _database;

  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    return await initDB();
  }

  Future<Database> initDB() async {
    final databasePath = await getDatabasesPath();
    logInfo(databasePath);
    final path = p.join(databasePath, 'ipsl_docs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTable(db);
      },
    );
  }

  Future<void> _createTable(Database db) async {
   await db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        filename TEXT,
        subject TEXT,
        classe TEXT,
        categorie TEXT,
        year TEXT
      );
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS user (
        id TEXT PRIMARY KEY,
        user_name TEXT,
        email TEXT,
        classe TEXT,
        number_contribution INT
      );
    ''');
  }




  Future<void> updateUser(String classe, String userName) async {
    Database db = await instance.database;
    await db.update("documents", {"user_name" : userName, "classe": classe});
  }

  Future<void> updateDocument(String filename, String id) async {
    Database db = await instance.database;
    await db.update("documents", {"filename" : filename}, whereArgs: [id], conflictAlgorithm: ConflictAlgorithm.replace);

  }

  Future<void> updateNumberContribution(int numberContribution) async {
    Database db = await instance.database;
    await db.update("users", {"number_contribution" : numberContribution});

  }

  Future<void> insertAllDoc(List<Document> data) async {
    Database db = await instance.database;
    // final data = await document_service.fetchDocuments();
    //  deleteAlldoc();

    for (var doc in data) {
      db.insert("documents",
          doc.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace
      );

    }
  }

  Future<List<Document>> getDocuments() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rawDocs = await db.query("documents");

    return rawDocs.map((row) => Document.fromJson(row)).toList();
  }

  Future<User> getUser() async {
    Database db = await instance.database;
List<Map<String, dynamic>> rawUsers = await db.query("users");
    Map<String, dynamic> rawUser = rawUsers.first;
User user = User.fromJson(rawUser);
return user;



  }
 /* Map<String, dynamic>? getUser() {
    final result = db.select("SELECT * FROM user");

    if (result.isEmpty) {
      return null;
    }

    return result
        .map(
          (row) => {
            'id': row['id'],
            'user_name': row['user_name'],
            'number_contribution': row['number_contribution'],
            'classe': row["classe"],
          },
        )
        .first;
  }*/

  /*void close() {
    instance.database.d
    //db.dispose();
  }*/

  Future<void> deleteAllUsers()  async{
    Database db =await instance.database;
    db.delete("users");
  }

  Future<void> deleteAlldoc() async{
    Database db =await instance.database;
    db.delete("documents");
  }

  Future<void> insertUser(User user)  async{
    Database db =await instance.database;
    deleteAllUsers();
   await db.insert( "users", user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertDocument(Document doc) async{
    Database db =await instance.database;
   await db.insert("documents", doc.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
