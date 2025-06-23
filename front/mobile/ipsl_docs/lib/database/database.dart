import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteService {
  late final Database db;

  SQLiteService._();

  static Future<SQLiteService> init() async {
    final instance = SQLiteService._();
    final dir = await getApplicationDocumentsDirectory();
    // logInfo(p.join(dir.path, 'ipsl_docs', 'ipsl_docs.db'));
    // final dbPath = p.join(dir.path, 'ipsl_docs', 'ipsl_docs.db');
    final dbPath = p.join(dir.path, 'ipsl_docs.db');

    instance.db = sqlite3.open(dbPath);

    instance.db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id TEXT PRIMARY KEY,
        idUploader TEXT,
        filename TEXT,
        filePath TEXT,
        categorie TEXT,
        isDownload INTEGER DEFAULT 0
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
    /*final data = [
      [1, "ex1.pdf", "cpi1/maths/devoirs", "devoirs", 1],
      [2, "td1.pdf", "cpi1/maths/td", "td", 1],
      [3, "tp1.docx", "cpi1/physique/tp", "tp", 1],
      [1, "utils_notes.pdf", "cpi1/physique/utils", "utils", 1],
      [2, "ex2.pdf", "cpi2/informatique/devoirs", "devoirs", 1],
      [3, "td2.pdf", "cpi2/informatique/td", "td", 1],
      [1, "tp2.docx", "cpi2/anglais/tp", "tp", 0],
      [2, "utils_code.pdf", "cpi2/anglais/utils", "utils", 1],
      [3, "ex3.pdf", "ing1/maths/devoirs", "devoirs", 1],
      [1, "td3.pdf", "ing1/maths/td", "td", 1],
      [2, "tp3.docx", "ing1/physique/tp", "tp", 1],
      [3, "utils_notes.pdf", "ing1/physique/utils", "utils", 1],
      [1, "ex4.pdf", "ing2/chimie/devoirs", "devoirs", 1],
      [2, "td4.pdf", "ing2/chimie/td", "td", 1],
      [3, "tp4.docx", "ing2/informatique/tp", "tp", 1],
      [1, "utils_codes.pdf", "ing2/informatique/utils", "utils", 1],
      [2, "ex5.pdf", "ing3/economie/devoirs", "devoirs", 1],
      [3, "td5.pdf", "ing3/economie/td", "td", 1],
      [1, "tp5.docx", "ing3/droit/tp", "tp", 0],
      [2, "utils_notes.pdf", "ing3/droit/utils", "utils", 1],
    ];*/
    final data = await document_service.fetchDocuments();

    for (var doc in data) {
      db.execute(
        '''
    INSERT INTO documents (id, idUploader, filename, filePath, categorie, isDownload)
    VALUES (?, ?, ?, ?, ?, ?);
  ''',
        [doc.id, doc.idUploader, doc.filename, doc.filePath, doc.categorie, 0],
      );
    }
  }

  List<Map<String, dynamic>> getDocuments() {
    final result = db.select('SELECT * FROM documents;');

    return result
        .map(
          (row) => {
            'id': row['id'],
            'idUploader': row['idUploader'],
            'filename': row['filename'],
            'filePath': row['filePath'],
            'categorie': row['categorie'],
            'isDownload': row['isDownload'],
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> getUser() {
    final result = db.select("SELECT * FROM user");
    return result
        .map(
          (row) => {
            'id': row['id'],
            'user_name': row['user_name'],
            'email': row['email'],
          },
        )
        .toList();
  }

  void close() {
    db.dispose();
  }

  void insertUser(Map<String, dynamic> user) {
    db.execute(
      '''
      INSERT INTO user (id, user_name, email)
      VALUES (?, ?, ?);
      ''',
      [user['id'], user['user_name'], user['email']],
    );
  }

  void insertDocument(Map<String, dynamic> doc) {
    db.execute(
      '''
    INSERT INTO documents (id, idUploader, filename, filePath, categorie, isDownload)
    VALUES (?, ?, ?, ?, ?, ?);
    ''',
      [
        doc['id'],
        doc['idUploader'],
        doc['filename'],
        doc['filePath'],
        doc['categorie'],
        doc['isDownload'] ?? 0,
      ],
    );
  }

  void setDocument(Document doc) {
    db.execute(
      '''
UPDATE documents SET isDownload = 1 WHERE id = ?;
''',
      [doc.id],
    );
  }
}
