import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/views/widgets/folder_home.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:open_file/open_file.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

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
                IconButton(
                  icon: folderHomeIcon(),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageTransition(
                        child: WidgetTree(),
                        type: PageTransitionType.fade,
                      ),
                      (route) => false,
                    );
                  },
                ),
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
                  String docPath = await getSavePath(doc);
                  if (await isExistFile(docPath) == false) {
                    final bool isConnected = await isConnectedToInternet();
                    if (isConnected == false) {
                      if (!context.mounted) return;
                      showNoConnectionMessage(context);
                      return;
                    }
                    doc.isDownloading = true;
                    await service.downloadFile(doc, (received, total) {
                      setState(() {
                        doc.progress = total != -1 ? received / total : 0;
                      });
                    });

                    setState(() {
                      doc.isDownloading = false;
                    });
                  }

          

                  await OpenFile.open(docPath);
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
                        doc.isDownloading
                            ? customCircularProgress(doc)
                            : FutureBuilder<Widget>(
                              future: _buildDocumentPreview(doc),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                } else if (snapshot.hasError ||
                                    !snapshot.hasData) {
                                  logInfo(snapshot.error.toString());
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

 

  Stack customCircularProgress(Document doc) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: doc.progress, // entre 0.0 et 1.0

            strokeWidth: 4,
            color: Colors.green,
          ),
        ),
        Text(
          '${(doc.progress * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

String getFileExtension(String fileName) {
  return fileName.split('.').last.toLowerCase();
}

/*Future<Widget> _buildDocumentPreview(Document doc) async {
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
  final fichier = File(savePath);

  if (!await fichier.exists()) {
    return Icon(Icons.download);
  }

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
  } else if (await isPDF(savePath)) {
    return FutureBuilder<Uint8List>(
      future: _generatePdfPreview(savePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          // return const Icon(Icons.picture_as_pdf, size: 64);
          return const Icon(Icons.error, size: 64);
        } else {
          return Image.memory(snapshot.data!, height: 100, fit: BoxFit.cover);
        }
      },
    );
  } else if (await isPPTFile(savePath)) {
    return FutureBuilder<Uint8List>(
      future: buildPptPreview(savePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          // return const Icon(Icons.picture_as_pdf, size: 64);
          return const Icon(Icons.error, size: 64);
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
}*/
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
  final fichier = File(savePath);

  if (!await fichier.exists()) {
    return Icon(Icons.download);
  }

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
    final pdfDocument = await PdfDocument.openFile(savePath);
    return SizedBox(
      width: 100,
      height: 100,
      child: PdfPageView(
        document: pdfDocument,
        pageNumber: 1,
        alignment: Alignment.center,
        pageSizeCallback: (widgetSize, page) {
          // Calcule un aperçu qui tient dans le carré tout en gardant le ratio
          final pageRatio = page.height / page.width;
          double previewWidth = widgetSize.width;
          double previewHeight = previewWidth * pageRatio;

          if (previewHeight > widgetSize.height) {
            // Ajuste pour que la hauteur rentre dans le carré
            previewHeight = widgetSize.height;
            previewWidth = previewHeight / pageRatio;
          }

          return Size(previewWidth, previewHeight);
        },
      ),
    );
  }

  // return Icon(Icons.insert_drive_file);

  return Icon(Icons.badge);
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
  /* final result = await Process.run('pdftoppm', [
    '-png',
    '-singlefile',
    '-f',
    '1',
    '-l',
    '1',
    pdfPath,
    outputBase,
  ]);*/
  logInfo(result.stderr);
  logInfo(result.stdout);

  if (result.exitCode != 0) {
    throw Exception("Erreur pdftoppm : ${result.stderr}");
  }

  final imageFile = File('$outputBase-1.png');
  if (!await imageFile.exists()) {
    // return Icon(Icons.exit_to_app);
    throw Exception("Image non trouvée après conversion.");
  }

  return await imageFile.readAsBytes();
}

Future<Uint8List> buildPptPreview(String pptPath) async {
  final tmpDir = Directory.systemTemp;
  final outputDir = Directory(
    '${tmpDir.path}/ppt_preview_${DateTime.now().millisecondsSinceEpoch}',
  );
  await outputDir.create();

  // Convertir le PPT(X) en images PNG
  final result = await Process.run('soffice', [
    '--headless',
    '--convert-to',
    'png',
    '--outdir',
    outputDir.path,
    pptPath,
  ]);
  logWarning(result.stderr);
  logWarning(result.stdout);

  if (result.exitCode != 0) {
    throw Exception(
      'Erreur lors de la conversion PowerPoint : ${result.stderr}',
    );
  }

  // Chercher la première image générée
  final outputFiles = outputDir.listSync().whereType<File>().toList();
  if (outputFiles.isEmpty) {
    throw Exception('Aucune image générée depuis le PowerPoint.');
  }

  // Trier les fichiers pour prendre la première slide
  outputFiles.sort((a, b) => a.path.compareTo(b.path));
  final firstImage = outputFiles.first;

  return await firstImage.readAsBytes();
}

Future<bool> isExistFile(String path) async {
  final fichier = File(path);
  return await fichier.exists();
}

Future<bool> isPDF(String path) async {
  final fichier = File(path);
  if (!await fichier.exists()) return false;

  final bytes = await fichier.openRead(0, 5).first;
  final signature = utf8.decode(bytes);

  return signature.startsWith('%PDF-');
}

Future<bool> isPPTFile(String chemin) async {
  final fichier = File(chemin);
  if (!await fichier.exists()) return false;

  final bytes = await fichier.openRead(0, 4).first;
  final signature = utf8.decode(bytes, allowMalformed: true);

  return signature.startsWith('PK'); // Indice d’un .pptx (ou autre .zip)
}
