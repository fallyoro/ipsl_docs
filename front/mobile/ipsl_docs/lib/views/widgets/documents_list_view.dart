import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:ipsl_docs/views/home.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class DocumentListView extends StatefulWidget {
  // final String folderPath;
  final List<Document> documents;

  const DocumentListView({
    super.key,
    // required this.folderPath,
    required this.documents,
  });

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  DocumentServive service = DocumentServive();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.folder_special, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.documents.first.classe} / ${widget.documents.first.year} / ${widget.documents.first.subject} / ${widget.documents.first.categorie}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
            ),
            itemCount: widget.documents.length,
            itemBuilder: (context, index) {
              final doc = widget.documents[index];

              return GestureDetector(
                onTap: () async {
                  if (widget.documents[index].isDownload == 0) {
                    await service.downloadFile(widget.documents[index], (
                      int sent,
                      int total,
                    ) {
                      logInfo('$sent $total');
                    });
                    setState(() {
                      widget.documents[index].isDownload = 1;
                    });
                    viewModel.setDocument(doc);
                  }

                  final baseDir = await getApplicationDocumentsDirectory();
                  final docDir = Directory(
                    p.join(
                      baseDir.path,
                      "ipsl_docs",
                      doc.classe,
                      doc.year.toString(),
                      doc.subject,
                      doc.categorie,
                    ),
                  );
                  if (!await docDir.exists()) {
                    await docDir.create(recursive: true);
                  }
                  final savePath = p.join(docDir.path, doc.filename);

                  /*  final directory = Directory(documentDirectory);
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }*/
                  await OpenFile.open(savePath);
                  // openDocument(savePath);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<Widget>(
                          future: _buildDocumentPreview(doc),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError || !snapshot.hasData) {
                              return const Icon(
                                Icons.insert_drive_file,
                                size: 64,
                              );
                            } else {
                              return snapshot.data!;
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doc.filename,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void openDocument(String path) async {
    logInfo('Platform.isLinux: ${Platform.isLinux}');
    logInfo(path);
    if (Platform.isLinux) {
      logInfo("try to open : $path");
      await Process.start('xdg-open', [path]);
    } else {
      logError("Platforme non supporte");
    }
  }
}

String getFileExtension(String fileName) {
  return fileName.split('.').last.toLowerCase();
}

Future<Widget> _buildDocumentPreview(Document doc) async {
  final baseDir = await getApplicationDocumentsDirectory();
  final docDir = Directory(
    p.join(
      baseDir.path,
      "ipsl_docs",
      doc.classe,
      doc.year.toString(),
      doc.subject,
      doc.categorie,
    ),
  );

  final savePath = p.join(docDir.path, doc.filename);
  final ext = getFileExtension(doc.filename);
  if (['jpg', 'jpeg', 'png'].contains(ext)) {
    final file = File(savePath);
    if (!file.existsSync()) {
      return Icon(FontAwesomeIcons.image);
    }
    return Image.file(
      file,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  } else if (ext == 'pdf') {
    return FutureBuilder<Uint8List>(
      future: _generatePdfPreview(savePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Icon(Icons.picture_as_pdf, size: 64);
        } else {
          return Image.memory(snapshot.data!, height: 100, fit: BoxFit.cover);
        }
      },
    );
  } else {
    return Image.asset(
      'assets/icons/${ext}_icon.png',
      height: 100,
      errorBuilder:
          (_, __, ___) => const Icon(Icons.insert_drive_file, size: 64),
    );
  }
}

Future<Uint8List> _generatePdfPreview(String pdfPath) async {
  final tmpDir = Directory.systemTemp;
  final outputBase =
      '${tmpDir.path}/preview_${DateTime.now().millisecondsSinceEpoch}';

  final result = await Process.run('pdftoppm', [
    '-png',
    '-f',
    '1',
    '-l',
    '1',
    pdfPath,
    outputBase,
  ]);

  if (result.exitCode != 0) {
    throw Exception("Erreur pdftoppm : ${result.stderr}");
  }

  final imageFile = File('$outputBase-1.png');
  if (!await imageFile.exists()) {
    throw Exception("Image non trouvée après conversion.");
  }

  return await imageFile.readAsBytes();
}
