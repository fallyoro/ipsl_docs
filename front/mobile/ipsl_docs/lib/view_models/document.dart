import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;

class DocumentViewModel {
  final DatabaseHelper _db;

  final ValueNotifier<List<Document>> documents = ValueNotifier([]);

  DocumentViewModel(this._db);

  Future<void> loadDocuments() async {
    documents.value = await _db.getDocuments();
  }

  Future<void> addDocument(Document doc) async {
    _db.insertDocument(doc);
    documents.value.add(doc);
  }

  void deleteAlldoc() {
    _db.deleteAlldoc();
  }

  void updateDocumentName(String newFilename, Document doc) {
    _db.updateDocument(newFilename, doc.id);

    final index = documents.value.indexWhere((oldDoc) => oldDoc.id == doc.id);
    if (index == -1) return; // Aucun document trouvé


    final dirDoc = p.dirname(doc.path);
    final newPath = p.join(dirDoc, newFilename);

    final updatedDoc = Document(
      id: doc.id,
      idUploader: doc.idUploader,
      path: newPath,
    );

    final File file = File(doc.path);
    file.rename(newPath);
    documents.value[index] = updatedDoc;
  }

  }
