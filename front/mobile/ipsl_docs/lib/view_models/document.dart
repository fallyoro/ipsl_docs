import 'package:flutter/material.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';

class DocumentViewModel {
  final SQLiteService _db;

  final ValueNotifier<List<Document>> documents = ValueNotifier([]);

  DocumentViewModel(this._db);

  Future<void> loadDocuments() async {
    // documents.value = [];
    final rawDocs = _db.getDocuments();

    documents.value = rawDocs.map((row) => Document.fromJson(row)).toList();
  }

  Future<void> addDocument(Document doc) async {
    _db.insertDocument(doc.toJson());
    documents.value.add(doc);
  }

  void deleteAlldoc() {
    _db.deleteAlldoc();
  }

  void updateDocumentName(String filename, String id) {
    _db.updateDocument(filename, id);

    final index = documents.value.indexWhere((doc) => doc.id == id);
    if (index == -1) return; // Aucun document trouvé

    final oldDoc = documents.value[index];

    final updatedDoc = Document(
      id: id,
      idUploader: oldDoc.idUploader,
      filename: filename,
      year: oldDoc.year,
      classe: oldDoc.classe,
      subject: oldDoc.subject,
      categorie: oldDoc.categorie,
    );

    documents.value[index] = updatedDoc;
  }

  List<String> getClasseFolders() {
    return documents.value.map((doc) => doc.classe).toSet().toList();
  }
}
