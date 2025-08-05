import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/Responsive.dart';
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
  final List<Document> documents;

  const DocumentListView({super.key, required this.documents});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  DocumentServive service = DocumentServive();
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileDevice = Responsive.isMobileDevice(context);
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
          body: buildDocumentGird(),
        );
      },
    );
  }

  GridView buildDocumentGird() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1,
      ),
      itemCount: widget.documents.length,
      itemBuilder: (context, index) {
        final doc = widget.documents[index];

        return GestureDetector(
          onSecondaryTapDown: (details) async {
            await deleteFileIfExist(
              context: context,
              doc: doc,
              onDeleted: () => setState(() {}),
            );
          },
          onLongPress: () async {
            await deleteFileIfExist(
              context: context,
              doc: doc,
              onDeleted: () => setState(() {}),
            );
          },

          onTap: () async {
            final isMobileDevice = Responsive.isMobileDevice(context);
            final ext = getFileExtension(doc.filename);
            if (ext == 'wxmx' && isMobileDevice) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Veillez ouvrir ce fichier avec votre pc"),
                ),
              );
              return;
            }

            String docPath = await getSavePath(doc);
            if (await isExistFile(docPath) == false) {
              final bool isConnected = await isConnectedToInternet();
              if (!isConnected) {
                // doc.isDownloading = false;
                if (!context.mounted || _isDisposed == true) return;
                showNoConnectionMessage(context);
                return;
              }

              try {
                // setState(() {
                doc.isDownloading.value = true;
                // });
                await service.downloadFile(doc, (received, total) {
                  if (!mounted || _isDisposed == true) return;
                  // setState(() {
                  doc.progress.value = total != -1 ? received / total : 0;
                  // });
                });
              } catch (e) {
                doc.isDownloading.value = false;

                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Serveur indisponible')));
              }
              if (!mounted || _isDisposed == true) return;

              doc.isDownloading.value = false;
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
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ValueListenableBuilder(
                    valueListenable: doc.isDownloading,
                    builder: (context, isDownloading, child) {
                      return isDownloading
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
                          );
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: BoxConstraints(maxWidth: 130),
                    child: Text(
                      doc.filename,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
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
          child: ValueListenableBuilder(
            valueListenable: doc.progress,
            builder: (context, progress, child) {
              return CircularProgressIndicator(
                value: progress, // entre 0.0 et 1.0

                strokeWidth: 4,
                color: Colors.green,
              );
            },
          ),
        ),
        ValueListenableBuilder(
          valueListenable: doc.progress,
          builder: (context, progress, child) {
            return Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            );
          },
        ),
      ],
    );
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
      doc.year,
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
            previewHeight = widgetSize.height;
            previewWidth = previewHeight / pageRatio;
          }

          return Size(previewWidth, previewHeight);
        },
      ),
    );
  } else if (ext == 'wxmx') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1000),
      child: Image.asset('assets/images/logo_maxima.png', height: 100),
    );
  }

  // return Icon(Icons.insert_drive_file);

  return Icon(Icons.error);
}

Future<bool> isExistFile(String path) async {
  final fichier = File(path);

  return await fichier.exists();
}

Future<void> showDeleteDialog({
  required BuildContext context,
  required File file,
  required VoidCallback onDeleted,
}) async {
  return showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Supprimer ce fichier"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await file.delete();
              onDeleted();
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

Future<void> deleteFileIfExist({
  required BuildContext context,
  required Document doc,
  required VoidCallback onDeleted, // callback pour mettre à jour le widget
}) async {
  final path = await getSavePath(doc);
  final file = File(path);
  if (!await file.exists()) return;
  if (!context.mounted) return;

  await showDeleteDialog(context: context, file: file, onDeleted: onDeleted);
}
