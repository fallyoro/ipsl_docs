import 'dart:io';
import 'package:ipsl_docs/src/pages/home/widget/preview_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import '../../../core/Responsive.dart';
import '../../../core/constant.dart';
import '../../../core/utils.dart';
import '../../../models/document.dart';
import '../../../services/document.dart';
import '../../../view_models/document.dart';
import 'custom_circular_progress.dart';
import 'delete_dialog.dart';

/*TODO: Ce fichier utilise directement le service DocumentService,
   il faudrait passer par le ViewModel pour respecter le pattern MVVM.
   Par consequent, refactoriser ce code pour utiliser le DocumentViewModel à la place du service directement.
   */

class DocumentListWidget extends StatefulWidget {
  final List<Document> documents;
  const DocumentListWidget({super.key, required this.documents});

  @override
  State<DocumentListWidget> createState() => _DocumentListWidgetState();
}

Future<void> cancelDoc(Document doc, DocumentService service) async {
  service.cancelDownload('Cancel by the user');
  doc.isDownloading.value = false;
  await deleteFile(doc);
}

class _DocumentListWidgetState extends State<DocumentListWidget> {
  bool _isDisposed = false;

  late final DocumentViewModel documentViewModel;
  late final DocumentService documentServive;
  final CancelToken _cancelToken =
      CancelToken(); // si tu utilises Dio, ou autre

  @override
  void dispose() {
    _isDisposed = true;
    _cancelToken.cancel(); // si besoin
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    documentViewModel = GetIt.I<DocumentViewModel>();
    documentServive = GetIt.I<DocumentService>();
  }

  void showNoConnectionMessage(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Pas de connexion Internet")));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      itemCount: widget.documents.length,
      itemBuilder: (context, index) {
        final doc = widget.documents[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final isMobileDevice = Responsive.isMobileDevice(context);
            final ext = doc.extension;
            final String docPath = await doc.localPath;
            if (ext == 'wxmx' && isMobileDevice) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Veillez ouvrir ce fichier avec votre PC"),
                ),
              );
              return;
            }
            if (await isExistFile(docPath) == false) {
              final bool isConnected = await isConnectedToInternet();
              if (!isConnected) {
                if (!context.mounted || _isDisposed) return;
                showNoConnectionMessage(context);
                return;
              }

              try {
                doc.isDownloading.value = true;
                await documentServive.downloadFile(doc, _cancelToken, (
                  received,
                  total,
                ) {
                  if (!mounted || _isDisposed) return;
                  doc.progress.value = total != -1 ? received / total : 0;
                });
              } catch (e) {
                doc.isDownloading.value = false;
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Serveur indisponible')),
                );
              }
              if (!mounted || _isDisposed) return;
              doc.isDownloading.value = false;
            }

            await OpenFile.open(docPath);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark ? AppColors.darkSystemBackground : Colors.grey[100],
            ),
            height: 120,
            child: Row(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: doc.isDownloading,
                  builder: (context, isDownloading, child) {
                    return isDownloading
                        ? SizedBox(
                          height: 100,
                          width: 100,
                          child: DocumentProgressWidget(
                            doc: doc,
                            onCancel: (d) async {
                              await cancelDoc(d, documentServive);
                              setState(() {});
                            },
                          ),
                        )
                        : previewWidget(
                          relativePath: doc.path,
                          context: context,
                        );
                  },
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Text(
                        doc.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.topCenter,
                  child: PopupMenuButton<String>(
                    color:
                        isDark
                            ? AppColors.darkSecondarySystemBackground
                            : Colors.white,
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await deleteFileIfExist(
                          context: context,
                          doc: doc,
                          onDeleted: () => setState(() {}),
                        );
                      } else if (value == 'share') {
                        final path = await getSavePath(doc);
                        if (!await isExistFile(path)) {
                          return;
                        }
                        final params = ShareParams(
                          text: 'Voici un document partagé via IPSL Docs',
                          files: [XFile(path)],
                        );
                        await SharePlus.instance.share(params);
                      }

                      final bool isConnected = await isConnectedToInternet();
                      if (!isConnected) {
                        if (!context.mounted || _isDisposed) return;
                        showNoConnectionMessage(context);
                        return;
                      }
                    },
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Text("Supprimer"),
                              Icon(Icons.delete, color: Colors.red),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: "share",
                          child: Row(
                            children: const [
                              Text("Partager"),
                              Icon(Icons.share, color: Colors.blue),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<bool> isExistFile(String path) async {
  final fichier = File(path);

  return await fichier.exists();
}

Future<void> deleteFile(Document doc) async {
  final path = await getSavePath(doc);
  final file = File(path);
  if (!await file.exists()) return;
  file.delete();
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
