import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import '../core/utils.dart';
import '../database/database.dart';
import '../models/document.dart';
import '../services/document.dart';
import 'directory_node.dart';

class DocumentViewModel {
  final DatabaseHelper _db;

  final ValueNotifier<DirectoryNode?> currentDirectory = ValueNotifier(null);
  final ValueNotifier<bool> isSending = ValueNotifier(false);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  final ValueNotifier<bool?> success = ValueNotifier(null);
  final ValueNotifier<PlatformFile?> pickedFileNotifier = ValueNotifier(null);
  final ValueNotifier<double> progress = ValueNotifier(0);
  final ValueNotifier<DirectoryNode?> root = ValueNotifier(null);
  final List<DirectoryNode> _stack = [];
  final DocumentService service;
  DocumentViewModel(this._db, this.service);

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

  Future<void> addDocument(Document doc) async {
    await _db.insertDocument(doc);
    await loadDocuments();
  }

  void goBack() {
    if (_stack.isNotEmpty) {
      final prev = _stack.removeLast();
      currentDirectory.value = prev;
    }
  }

  void goHome() {
    if (root.value != null) {
      _stack.clear();
      currentDirectory.value = root.value;
    }
  }

  Future<void> loadDocuments() async {
    final documents = await _db.getDocuments();
    final rootNode = _buildTree(documents);
    _stack.clear();
    root.value = rootNode;
    currentDirectory.value = rootNode;
  }

  /// Ouvre un dossier : push l'ancien dossier sur la pile puis change current
  void openDirectory(DirectoryNode directory) {
    if (currentDirectory.value != null) {
      _stack.add(currentDirectory.value!);
    }
    currentDirectory.value = directory;
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      final String? error = await validateDocument(file.path!);
      if (error != null) {
        logError(error);
        errorNotifier.value = error;
        return;
      }

      pickedFileNotifier.value = file;
    }
  }

  void reset() {
    progress.value = 0;
    isSending.value = false;
    pickedFileNotifier.value = null;
  }

  Future<String?> submitDocument({
    required BuildContext context,
    required String path,
    required String fileName,
  }) async {
    isSending.value = true;

    UserViewModel userViewModel = GetIt.instance<UserViewModel>();
    final String? error = await validateFileExtension(fileName);
    if (error != null) {
      logError("The erroroooooooooooooooo");
      logError(error);
      errorNotifier.value = error;
      return error;
    }
    final result = await service.uploadDocument(
      file: File(pickedFileNotifier.value!.path!),
      path: path,
      userId: userViewModel.userNotifier.value!.id,
      onProgress: (received, total) {
        updateProgress(received, total);
      },
    );
    result.fold(
      (failure) {
        errorNotifier.value = failure.message;
        reset();
      },
      (docData) async {
        success.value = true;
        reset();
        final doc = Document(
          id: docData['id'],
          idUploader: userViewModel.userNotifier.value!.id,
          path: path,
          updatedAt: DateTime.parse(docData['updated_at'] as String),
        );
        await addDocument(doc);

        final int numberContribution = docData['number_contribution'];
        await userViewModel.updateNumberContribution(numberContribution);
        // confirmSending();
        await loadDocuments();
      },
    );
    return null;
  }

  //sync documents from remote server using the variable updatedAt(each document has its own value) in the document model
  Future<void> syncDocumentFromServer() async {
    final List<Map<String, dynamic>> docFetch = await service.fetchDocuments();
    logInfo(docFetch.toString());
    for (Map<String, dynamic> doc in docFetch) {
      if (doc['is_deleted'] == true) {
        await _db.deleteDocument(doc['id']);
      } else {
        Document updatedDoc = Document.fromJson(doc);
        await _db.insertDocument(updatedDoc);
      }
    }
    //await loadDocuments();
    /*for (Document doc in localDocument) {
      Map<String, dynamic>? remoteDoc = docFetch.firstWhere((element) {
       return doc.id == element['id'];

      } );
      if (remoteDoc != null) {

        DateTime remoteDocumentupDateAt = DateTime.parse(remoteDoc['updated_at']);

      }
    }*/
  }

  Future<void> updateDocumentName(String newFilename, Document doc) async {
    await _db.updateDocumentName(newFilename, doc.id);
    await loadDocuments();

    final dirDoc = p.dirname(doc.path);
    final newPath = p.join(dirDoc, newFilename);

    final File file = File(doc.path);
    file.rename(newPath);
  }

  void updateProgress(int received, int total) {
    if (total > 0) {
      progress.value = received / total;
    } else {
      progress.value = 0;
    }
  }

  Future<String?> validateDocument(String path) async {
    /* This function check if the document submited is valid
  if it's valid it return null else it return a String
  also this function affect a value to errorNotifier
  wtf ma mene bine commentaire
  */
    final parts = path.split('.');
    if (parts.length < 2) return "Fichier sans extension.";
    final String extension = parts.last.toLowerCase();
    final file = File(path);
    final mimeType = lookupMimeType(path);
    const pdfExtensions = ['pdf'];
    final bool isPdf =
        mimeType == 'application/pdf' && pdfExtensions.contains(extension);
    if (!isPdf) {
      final String error = "Seuls les fichiers PDF sont autorisés.";
      return error;
    }
    final bytes = await file.length();
    final mb = bytes / (1024 * 1024);
    if (mb > 50) {
      final String error =
          "Fichier trop volumineux.\nLa taille maximale autorisée est de 50 Mo.";
      return error;
    }
    return null;
  }

  // This function compare the extionsion provide by the the user and the extension of the file
  Future<String?> validateFileExtension(String fileName) async {
    final String path = pickedFileNotifier.value?.path ?? '';
    if (path.isEmpty) return "Aucun fichier sélectionné";

    final trimmedName = fileName.trim();
    final partsUser = trimmedName.split('.');
    final partsFile = path.split('/').last.split('.');

    if (partsUser.length < 2 || partsFile.length < 2) {
      return "Fichier ou nom incomplet (pas d'extension)";
    }

    final String extensionUser = partsUser.last.toLowerCase();
    final String extensionFile = partsFile.last.toLowerCase();

    if (extensionUser != extensionFile) {
      return "Incohérence dans l'extension";
    }

    return null;
  }

  String? validateFileName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Champ requis';
    }
    if (value.length > 50) {
      return "Nom de fichier trop long (50 caractères max).";
    }

    if (value.contains(RegExp(r'[\/\\]'))) {
      return "Caractère non autorisé dans le nom du fichier";
    }
    if (value.split(".").length < 2) {
      return "Fichier ou nom incomplet (pas d'extension)";
    }
    return null;
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

    root.subDirectories.sort((a, b) {
      if (a.name == "Général") return -1;
      if (b.name == "Général") return 1;
      return a.name.compareTo(b.name);
    });
    return root;
  }
}
