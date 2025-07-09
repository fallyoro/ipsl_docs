import 'package:ipsl_docs/core/notifiers.dart';
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
        year INTEGER,
        is_download INTEGER DEFAULT 0
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

  Future<void> insertMockData() async {
    final data = await document_service.fetchDocuments();

    for (var doc in data) {
      db.execute(
        '''
    INSERT OR REPLACE INTO documents (id, user_id, filename, classe, year,  categorie, subject, is_download)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?);
  ''',
        [
          doc.id,
          doc.idUploader,
          doc.filename,
          doc.classe,
          doc.year,
          doc.categorie,
          doc.subject,
          0,
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
            'is_download': row['is_download'],
          },
        )
        .toList();
  }

  // Todo add .first
  Map<String, dynamic> getUser() {
    final result = db.select("SELECT * FROM user");

    if (result.isEmpty) {
      return {'id': 'id', 'user_name': 'user_name', 'email': 'email'};
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
    INSERT OR REPLACE INTO documents (id, user_id, filename, classe, year, categorie, subject, is_download)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    ''',
      [
        doc['id'],
        doc['user_id'],
        doc['filename'],
        doc['classe'],
        doc['year'],
        doc['categorie'],
        doc['subject'],
        doc['is_download'] ?? 0,
      ],
    );
  }

  void setDocument(Document doc) {
    db.execute(
      '''
UPDATE documents SET is_download = 1 WHERE id = ?;
''',
      [doc.id],
    );
  }
}
