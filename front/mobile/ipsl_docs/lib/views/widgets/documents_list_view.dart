import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/views/home.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DocumentListView extends StatefulWidget {
  final String folderPath;
  final List<Document> documents;

  const DocumentListView({
    super.key,
    required this.folderPath,
    required this.documents,
  });

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  DocumentServive service = DocumentServive();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contenu de ${widget.folderPath}')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 2,
        ),
        itemCount: widget.documents.length,
        itemBuilder: (context, index) {
          final doc = widget.documents[index];
          return GestureDetector(
            onTap: () async {
              // Action future : ouvrir fichier, prévisualiser, etc.
              if (widget.documents[index].isDownload == 0) {
                await service.downloadFile(widget.documents[index]);
                setState(() {
                  widget.documents[index].isDownload = 1;
                });
                viewModel.setDocument(doc);
              }
              final dir = await getApplicationDocumentsDirectory();
              final String goodPath =
                  "ipsl_docs/${widget.documents[index].filePath}/${widget.documents[index].filename}";
              final String fullDirPath =
                  "${dir.path}/ipsl_docs/${widget.documents[index].filePath}";
              final directory = Directory(fullDirPath);
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
              logInfo(goodPath);
              openDocument(goodPath);
            },
            child: ValueListenableBuilder(
              valueListenable: ThemeController.isDarkModeNotifier,
              builder: (context, isDark, child) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.darkSecondarySystemBackground
                            : AppColors.lightSecondarySystemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          doc.filename,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          doc.categorie,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        //SpinKitRotatingCircle(color: Colors.white, size: 50.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void openDocument(String path) async {
    final dir = await getApplicationDocumentsDirectory();
    logInfo("dir : $dir");
    final String completePath = "$dir/$path";
    logInfo("completepath : $completePath");
    logInfo('Platform.isLinux: ${Platform.isLinux}');
    logInfo(path);
    if (Platform.isLinux) {
      // dir is a Directory object, so dir.toString() gives "Directory: '/path'"
      // We need the path as a string, not the Directory's toString().
      final dirPath = dir.path;
      final String completePath = "$dirPath/$path";
      logInfo("fixed completepath : $completePath");
      await Process.start('xdg-open', [completePath]);
    } else {
      logError("Platforme non supporte");
    }
  }
}
