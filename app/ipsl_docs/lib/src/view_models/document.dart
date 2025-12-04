import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'dart:io';
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
  PlatformFile? pickedFile;
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

  void goHome() {
    if (root.value != null) {
      _stack.clear();
      currentDirectory.value = root.value;
    }
  }

  /// Ouvre un dossier : push l'ancien dossier sur la pile puis change current
  void openDirectory(DirectoryNode directory) {
    if (currentDirectory.value != null) {
      _stack.add(currentDirectory.value!);
    }
    currentDirectory.value = directory;
  }

  void goBack() {
    if (_stack.isNotEmpty) {
      final prev = _stack.removeLast();
      currentDirectory.value = prev;
    }
  }

  Future<void> loadDocuments() async {
    final documents = await _db.getDocuments();
    final rootNode = _buildTree(documents);
    _stack.clear();
    root.value = rootNode;
    currentDirectory.value = rootNode;
  }

  Future<void> addDocument(Document doc) async {
    await _db.insertDocument(doc);
    await loadDocuments();
  }

  Future<void> updateDocumentName(String newFilename, Document doc) async {
    await _db.updateDocumentName(newFilename, doc.id);
    await loadDocuments();

    final dirDoc = p.dirname(doc.path);
    final newPath = p.join(dirDoc, newFilename);

    final File file = File(doc.path);
    file.rename(newPath);
  }

  //sync documents from remote server using the variable updatedAt(each document has its own value) in the document model
  Future<void> syncDocumentFromServer() async {
    final List<Map<String, dynamic>> docFetch =
        await service.fetchRawDocuments();
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

  void updateProgress(int received, int total) {
    if (total > 0) {
      progress.value = received / total;
    } else {
      progress.value = 0;
    }
  }

  void reset() {
    progress.value = 0;
    pickedFile = null;
  }

  Future<void> validateDocument(Document doc) async {
    final String path = await doc.localPath;
    final mimtype = lookupMimeType(path);
    if (mimtype == "application/pdf" || mimtype!.startsWith("image")) {
      return;
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      pickedFile = file;
    }
  }

  // Future<void> submit(BuildContext context) async {
  Future<void> submitDocument({
    required BuildContext context,
    required String path,
  }) async {
    isSending.value = true;
    if (!await isConnectedToInternet()) {
      isSending.value = false;
      if (!context.mounted) return;
      showNoConnectionMessage(context);
      return;
    }

    UserViewModel userViewModel = GetIt.instance<UserViewModel>();
    final responseUpload = await service.uploadDocument(
      file: File(pickedFile!.path!),
      path: path,
      userId: userViewModel.userNotifier.value!.id,
      onProgress: (received, total) {
        updateProgress(received, total);
      },
    );
    if (responseUpload == null) {
      errorNotifier.value = "Erreur : Impossible d'envoyer le fichier";
      return;
    }
    final doc = Document(
      id: responseUpload['id'],
      idUploader: userViewModel.userNotifier.value!.id,
      path: path,
      updatedAt: DateTime.parse(responseUpload['updated_at'] as String),
    );
    await addDocument(doc);

    final int numberContribution = responseUpload['number_contribution'];
    await userViewModel.updateNumberContribution(numberContribution);
    // await loadDocuments();
    isSending.value = false;
    reset();
  }
}
