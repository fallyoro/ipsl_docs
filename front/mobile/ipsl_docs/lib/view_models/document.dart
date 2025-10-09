import 'package:flutter/material.dart';
import 'dart:io';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;
import 'package:ipsl_docs/view_models/directory_node.dart';

import '../core/utils.dart';

class DocumentViewModel {
  final DatabaseHelper _db;

  final ValueNotifier<DirectoryNode?> currentDirectory = ValueNotifier(null);
  final ValueNotifier<DirectoryNode?> root = ValueNotifier(null);
  final List<DirectoryNode> _stack = [];
  final ValueNotifier<bool> canGoBackNotifier = ValueNotifier(false);
  DocumentViewModel(this._db);

  bool get canGoBack => _stack.isNotEmpty;
  //getter if the current directory in name General
  bool get isInGeneral {
    if (currentDirectory.value == null) return false;
    return currentDirectory.value!.name == "Général";
  }
  bool get isInConcours {
    if (currentDirectory.value == null) return false;
    return currentDirectory.value!.name == "Concours";
  }

  //get current path for the breadcrumb.
  List<String> get currentPath {
    if (currentDirectory.value == null) return [];
    List<String> path = [];
    for (var dir in _stack) {
      path.add(dir.name);
    }
    path.add(currentDirectory.value!.name);
    path.removeAt(0); // remove the root "IPSL Docs"
    return path;
  }

  DirectoryNode _buildTree(List<Document> docs) {
    final DirectoryNode root = DirectoryNode(
      name: "IPSL Docs",
      subDirectories: [],
    );

    for (var doc in docs) {
      final parts = doc.path.split(
        "/",
      ); // ["Cours", "Informatique", "Algo.pdf"]
      DirectoryNode current = root;

      for (int i = 0; i < parts.length; i++) {
        final part = parts[i];

        if (i == parts.length - 1) {
          // Dernière partie → c’est un fichier
          current.documents.add(doc);
        } else {
          // C’est un dossier
          var sub = current.subDirectories.firstWhere(
            (d) => d.name == part,
            orElse: () {
              final newDir = DirectoryNode(
                name: part,
                subDirectories: [],
                documents: [],
              );
              current.subDirectories.add(newDir);
              return newDir;
            },
          );
          current = sub;
        }
      }
    }

    logInfo("the root node : ${root.subDirectories.toString()}");
    //    root.subDirectories.sort((a, b) => a.name.compareTo(b.name));
    root.subDirectories.sort((a, b) {
      if (a.name == "Général") return -1;
      if (b.name == "Général") return 1;
      return a.name.compareTo(b.name);
    });
    return root;
  }

  void goHome() {
    if (root.value != null) {
      _stack.clear();
      currentDirectory.value = root.value;
      canGoBackNotifier.value = false;
    }
  }

  /// Ouvre un dossier : push l'ancien dossier sur la pile puis change current
  void openDirectory(DirectoryNode directory) {
    if (currentDirectory.value != null) {
      _stack.add(currentDirectory.value!);
      canGoBackNotifier.value = _stack.isNotEmpty;
    }
    currentDirectory.value = directory;
  }

  void goBack() {
    if (_stack.isNotEmpty) {
      final prev = _stack.removeLast();
      currentDirectory.value = prev;
      canGoBackNotifier.value = _stack.isNotEmpty;
    }
  }

  Future<void> loadDocuments() async {
    final documents = await _db.getDocuments();
    final rootNode = _buildTree(documents);
    _stack.clear();
    root.value = rootNode;
    currentDirectory.value = rootNode;
    canGoBackNotifier.value = _stack.isNotEmpty;
  }

  Future<void> addDocument(Document doc) async {
    await _db.insertDocument(doc);
    await loadDocuments();
  }

  Future<void> deleteAlldoc() async {
    await _db.deleteAlldoc();
    root.value = null;
  }

  Future<void> updateDocumentName(String newFilename, Document doc) async {
    await _db.updateDocument(newFilename, doc.id);
    await loadDocuments();

    final dirDoc = p.dirname(doc.path);
    final newPath = p.join(dirDoc, newFilename);

    final File file = File(doc.path);
    file.rename(newPath);
  }
}
