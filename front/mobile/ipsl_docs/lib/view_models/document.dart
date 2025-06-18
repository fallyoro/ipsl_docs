import 'package:flutter/material.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';

import 'package:flutter/material.dart';


class DocumentViewModel {
  final SQLiteService _db;

  /// Liste complète des documents
  final ValueNotifier<List<Document>> documents = ValueNotifier([]);

  DocumentViewModel(this._db);

  Future<void> loadDocuments() async {
    final rawDocs = _db.getDocuments();
    documents.value = rawDocs.map((row) => Document.fromJson(row)).toList();
  }

  Future<void> addDocument(Document doc) async {
    _db.insertDocument(doc.toJson());
    await loadDocuments();
  }

  /// Obtenir les chemins de répertoire de premier niveau (ex: cpi1, ing2...)
  List<String> getRootFolders() {
    return documents.value
        .map((doc) => doc.filePath.split('/').first)
        .toSet()
        .toList();
  }

  /// Obtenir les documents par chemin exact
  List<Document> getDocumentsByPath(String path) {
    return documents.value.where((d) => d.filePath == path).toList();
  }
}

