import 'package:flutter/material.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';

class DocumentViewModel {
  final SQLiteService _db;

  final ValueNotifier<List<Document>> documents = ValueNotifier([]);

  DocumentViewModel(this._db);

  Future<void> loadDocuments() async {
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

  List<String> getClasseFolders() {
    return documents.value.map((doc) => doc.classe).toSet().toList();
  }

  
}
