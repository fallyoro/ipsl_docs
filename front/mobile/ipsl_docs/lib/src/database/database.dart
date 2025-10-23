
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../core/utils.dart';
import '../models/document.dart';
import '../models/user.dart';

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
        path TEXT,
        updated_at TEXT
      );
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        user_name TEXT,
        classe TEXT,
        number_contribution INT
      );
    ''');
  }

  Future<void> updateUser(String classe, String userName) async {
    Database db = await instance.database;
    await db.update("users", {"user_name": userName, "classe": classe});
  }

  Future<void> updateDocumentName(String filename, String id) async {
    Database db = await instance.database;
    await db.update(
      "documents",
      {"filename": filename},
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateDocument(Document doc) async {
    Database db = await instance.database;
    await db.update(
      "documents",
      doc.toJson(),
      where: 'id = ?',
      whereArgs: [doc.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDocument(String id) async {
    Database db = await instance.database;
    await db.delete("documents", where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Document>> loadDirectory(String parentPath) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> rawDocuments = await db.query(
      "documents",
      where: 'path LIKE ?',
      whereArgs: ["$parentPath%"],
    );
    final List<Document> allDocuments =
        rawDocuments.map((e) => Document.fromJson(e)).toList();
    return allDocuments;
  }

  Future<void> updateNumberContribution(int numberContribution) async {
    Database db = await instance.database;
    await db.update("users", {"number_contribution": numberContribution});
  }

  Future<void> insertAllDoc(List<Document> data) async {
    Database db = await instance.database;
    // final data = await document_service.fetchDocuments();
    //  deleteAlldoc();

    for (var doc in data) {
      try {
        db.insert(
          "documents",
          doc.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (e) {
        logInfo("Error inserting document: $e");
      }
    }
  }

  Future<List<Document>> getDocuments() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rawDocs = await db.query("documents");

    return rawDocs.map((row) => Document.fromJson(row)).toList();
  }

  Future<User?> getUser() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> rawUsers = await db.query("users");
    logInfo(rawUsers.toString());
    if (rawUsers.isEmpty) {
      return null;
    }

    Map<String, dynamic> rawUser = rawUsers.first;

    logInfo(rawUser.toString());
    User user = User.fromJson(rawUser);
    logInfo("There is a user");

    return user;
  }

  /*void close() {
    instance.database.d
    //db.dispose();
  }*/

  Future<void> deleteAllUsers() async {
    Database db = await instance.database;
    db.delete("users");
  }

  Future<void> deleteAlldoc() async {
    Database db = await instance.database;
    db.delete("documents");
  }

  Future<void> insertUser(User user) async {
    Database db = await instance.database;
    await deleteAllUsers();
    await db.insert(
      "users",
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertDocument(Document doc) async {
    Database db = await instance.database;
    await db.insert(
      "documents",
      doc.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getSubjects() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      "documents",
      distinct: true,
      columns: ['path'],
    );
    List<String> subject = result.map((e) => e['path'] as String).toList();
    //We do not want concour and general documents. This is wierd but I will refactor all the code later.
    subject.removeWhere((element) => element.split("/").length != 5);
    //for path return the second element
    subject.map((e) => e.split("/")[1]).toSet().toList();
    subject.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return subject;
  }
}
