import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteService {
  late final Database db;

  SQLiteService._();
  static final SQLiteService instance = SQLiteService._();

  static Future<SQLiteService> init() async {
    // final instance = SQLiteService._();
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'ipsl_docs.db');

    instance.db = sqlite3.open(dbPath);

    instance.db.execute('''
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
    instance.db.execute('''
      CREATE TABLE IF NOT EXISTS user (
        id TEXT PRIMARY KEY,
        user_name TEXT,
        email TEXT
      );
    ''');

    return instance;
  }

  Future<void> insertAllDoc(List<Document> data) async {
 
    // final data = await document_service.fetchDocuments();
      //  deleteAlldoc();

    for (var doc in data) {
      db.execute(
        '''
    INSERT OR REPLACE INTO documents (id, user_id, filename, classe, year,  categorie, subject)
    VALUES (?, ?, ?, ?, ?, ?, ?);
  ''',
        [
          doc.id,
          doc.idUploader,
          doc.filename,
          doc.classe,
          doc.year,
          doc.categorie,
          doc.subject,
        ],
      );
    }
  }

  List<Map<String, dynamic>> getDocuments() {
    final result = db.select('SELECT * FROM documents;');

    return result
        .map(
          (row) => {
            'id': row['id'],
            'user_id': row['user_id'],
            'filename': row['filename'],
            'classe': row['classe'],
            'year': row['year'],
            'subject': row['subject'],
            'categorie': row['categorie'],
          },
        )
        .toList();
  }

  // Todo add .first
  Map<String, dynamic>? getUser() {
    final result = db.select("SELECT * FROM user");

    if (result.isEmpty) {
      return null;
    }

    return result
        .map(
          (row) => {
            'id': row['id'],
            'user_name': row['user_name'],
            'email': row['email'],
          },
        )
        .first;
  }

  void close() {
    db.dispose();
  }

  void deleteAllUsers() {
    db.execute('''
    DELETE FROM user;
    ''');
  }

  void deleteAlldoc() {
    db.execute('''
  DELETE FROM documents
''');
  }

  void insertUser(Map<String, dynamic> user) {
    deleteAllUsers();
    db.execute(
      '''
      INSERT OR REPLACE INTO user (id, user_name, email)
      VALUES (?, ?, ?);
      ''',
      [user['id'], user['user_name'], user['email']],
    );
  }

  void insertDocument(Map<String, dynamic> doc) {
    db.execute(
      '''
    INSERT OR REPLACE INTO documents (id, user_id, filename, classe, year, categorie, subject)
    VALUES (?, ?, ?, ?, ?, ?, ?);
    ''',
      [
        doc['id'],
        doc['user_id'],
        doc['filename'],
        doc['classe'],
        doc['year'],
        doc['categorie'],
        doc['subject'],
      ],
    );
  }
}
