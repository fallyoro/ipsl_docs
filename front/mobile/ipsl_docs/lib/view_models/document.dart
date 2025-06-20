import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';

class DocumentViewModel {
  final SQLiteService _db;


  final ValueNotifier<List<Document>> documents = ValueNotifier([]);

  DocumentViewModel(this._db);

  Future<void> loadDocuments() async {
    final rawDocs = _db.getDocuments();
    logInfo("The documents");

    documents.value = rawDocs.map((row) => Document.fromJsonForDatabase(row)).toList();
    logInfo("Info of first document");
    for (int i = 0; i < 3; i++) {
      logInfo("File path");
      logInfo(documents.value[i].filePath);
      logInfo("File name");
      logInfo(documents.value[i].filename);
    }
  }

  Future<void> addDocument(Document doc) async {
    _db.insertDocument(doc.toJson());
    await loadDocuments();
  }


  List<String> getRootFolders() {
    return documents.value
        .map((doc) => doc.filePath.split('/').first)
        .toSet()
        .toList();
  }

  List<String> getsubFolders() {
    return documents.value
        .map((doc) => doc.filePath.split('/')[1])
        .toSet()
        .toList();
  }


  List<Document> getDocumentsByPath(String path) {
    return documents.value.where((d) => d.filePath == path).toList();
  }
}
