//import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteService {
  late final Database db;

  SQLiteService._(); // constructeur privé

  static Future<SQLiteService> init() async {
    final instance = SQLiteService._();
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'ipsl_docs.db');

    instance.db = sqlite3.open(dbPath);

    instance.db.execute('''
      CREATE TABLE IF NOT EXISTS documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_Uploader TEXT,
        filename TEXT,
        filePath TEXT,
        categorie TEXT,
        isDownload INTEGER DEFAULT 1
      );
    ''');
    instance.db.execute('''
      CREATE TABLE IF NOT EXISTS user (
        id INTEGER,
        nom TEXT,
        prenom TEXT,
        email TEXT
      );
    ''');

    return instance;
  }

  void insertMockData() {
    final data = [
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
    ];

    for (var row in data) {
      db.execute('''
        INSERT INTO documents (id_Uploader, filename, filePath, categorie, isDownload)
        VALUES (?, ?, ?, ?, ?);
      ''', row);
    }
  }

  List<Map<String, dynamic>> getDocuments() {
    final result = db.select('SELECT * FROM documents;');
    return result
        .map(
          (row) => {
            'id': row['id'],
            'id_Uploader': row['id_Uploader'],
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
            'nom': row['nom'],
            'prenom': row['prenom'],
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
      INSERT INTO user (id, nom, prenom, email)
      VALUES (?, ?, ?, ?);
      ''',
      [
        user['id'],
        user['nom'],
        user['prenom'],
        user['email'],
      ],
    );
  }

  void insertDocument(Map<String, dynamic> doc) {
    db.execute(
      '''
      INSERT INTO documents (id_Uploader, filename, filePath, categorie, isDownload)
      VALUES (?, ?, ?, ?, ?);
    ''',
      [
        doc['id_Uploader'],
        doc['filename'],
        doc['filePath'],
        doc['categorie'],
        doc['isDownload'] ?? 0, // valeur par défaut
      ],
    );
  }
}





/*Document({
    required this.id,
    required this.idUploader,
    required this.filename,
    required this.filePath,
    required this.categorie,
  });*/

  /// Ajouter un Todo avec gestion correcte de l'auto-incrément
  /*static Future<Todo> addTodo(Todo todo) async {
    final db = await database;
    int id = await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Tâche ajoutée avec ID : $id');
    

    return Todo(
      id: id, // ID généré automatiquement par SQLite
      title: todo.title,
      description: todo.description,
      date: todo.date,
      isComplete: todo.isComplete,
    );
  }

  /// Récupérer tous les Todos
  static Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    print("Tâches récupérées: $maps");

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  /// Supprimer un Todo avec vérification
  static Future<void> deleteTodo(int id) async {
    final db = await database;
    final int result =
        await db.delete('todos', where: 'id = ?', whereArgs: [id]);

    if (result == 0) {
      print('Aucune tâche trouvée pour être supprimée.');
    } else {
      print('Tâche supprimée.');
    }
  }

  /// Supprimer tous les Todos (correction de la fonction)
  static Future<void> deleteAllTodos() async {
    final db = await database;
    await db.delete('todos');
    print("Toutes les tâches ont été supprimées.");
  }

  /// Mettre à jour un Todo
  static Future<void> updateTodo(Todo todo) async {
    final db = await database;
    int result = await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );

    if (result == 0) {
      print("Erreur : Aucune tâche mise à jour.");
    } else {
      print("Tâche mise à jour avec succès.");
    }
  }
}
*/