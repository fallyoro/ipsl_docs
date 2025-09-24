import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home/widget/appbar.dart';
import 'package:ipsl_docs/views/home/widget/bottom_sheet.dart';
import 'package:ipsl_docs/views/home/widget/search.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/view_models/navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../services/document.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final UserViewModel userViewModel;
  late final NavigationViewModel navigationViewModel;
  late final DocumentViewModel documentViewModel;
  bool isLoading = false;
  bool _hasFetched = false;
  String errorMessage = "";

  DocumentServive service = DocumentServive();
  bool _isDisposed = false;
  late CancelToken _cancelToken;

  // String userName = "hello";
  Responsive responsive = Responsive();

  @override
  void initState() {
    super.initState();
    userViewModel = GetIt.instance<UserViewModel>();
    userViewModel.getUser();
    navigationViewModel = GetIt.instance<NavigationViewModel>();
    documentViewModel = GetIt.I<DocumentViewModel>();
    // userName = userViewModel.userNotifier.value.userName;
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final bool isConnected = await isConnectedToInternet();
    try {
      if (isConnected & !_hasFetched) {
        final data = await document_service.fetchDocuments();
        _hasFetched = true;

        DatabaseHelper.instance.deleteAlldoc();
        DatabaseHelper.instance.insertAllDoc(data);
        documentViewModel.loadDocuments();
      }
    } catch (e) {
      errorMessage = 'Erreur lors du chargement : $e';
    }
    _hasFetched = false;
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
        IconButton(
          onPressed: () async {
            await cancelDoc(doc);
            setState(() {});
          },
          icon: Icon(FontAwesomeIcons.xmark),
        ),
        /*  ValueListenableBuilder(
          valueListenable: doc.progress,
          builder: (context, progress, child) {
            return
              return Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            );
          },
        ),*/
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool inDocumentListView =
        navigationViewModel.currentPath.value.split("/").length == 1;

    final documentsList = documentViewModel.documents.value;
    // final documentClass = documentsList.map((d) => d.classe).toSet().toList();

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<Document>>(
      valueListenable: documentViewModel.documents,
      builder: (context, docs, _) {
        return Scaffold(
          appBar: AppBar(
            title: ValueListenableBuilder(
              valueListenable: navigationViewModel.currentPath,
              builder: (context, value, child) => Text(value),
            ),
            leading: IconButton(
              onPressed: navigationViewModel.goBack,
              icon: Icon(Icons.arrow_back),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              builBottomSheetUpload(context);
            },
            child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
          ),
          backgroundColor: AppColors.primaryColor,

          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                CustomSliverAppBar(isDark),
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),

                    child: ValueListenableBuilder(
                      valueListenable: ThemeController.isDarkModeNotifier,
                      builder: (context, isDark, child) {
                        return Stack(
                          children: [
                            ValueListenableBuilder(
                              valueListenable: userViewModel.userNotifier,
                              builder: (context, user, child) {
                                return Container(
                                  padding: EdgeInsets.only(
                                    bottom: 90,
                                    left: 20,
                                    right: 20,
                                  ),
                                  color: AppColors.primaryColor,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: 'Bienvenue 👋, ',
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: user.userName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      //Search(documents: documentsList),
                                    ],
                                  ),
                                );
                              },
                            ),

                            Positioned(
                              top: 160,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? AppColors
                                              .darkSecondarySystemBackground
                                          : AppColors.lightSystemBackground,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                child:
                                    inDocumentListView
                                        ? ListView.separated(
                                          separatorBuilder:
                                              (context, index) =>
                                                  SizedBox(height: 30),

                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 30,
                                          ),

                                          itemCount: docs.length,
                                          itemBuilder: (context, index) {
                                            final doc = docs[index];
                                            final String fileName = p.basename(
                                              doc.path,
                                            );

                                            return GestureDetector(
                                              behavior: HitTestBehavior.opaque,

                                              onTap: () async {
                                                final isMobileDevice =
                                                    Responsive.isMobileDevice(
                                                      context,
                                                    );
                                                final ext = getFileExtension(
                                                  fileName,
                                                );
                                                if (ext == 'wxmx' &&
                                                    isMobileDevice) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Veillez ouvrir ce fichier avec votre pc",
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                String docPath =
                                                    await getSavePath(doc);
                                                if (await isExistFile(
                                                      docPath,
                                                    ) ==
                                                    false) {
                                                  final bool isConnected =
                                                      await isConnectedToInternet();
                                                  if (!isConnected) {
                                                    // doc.isDownloading = false;
                                                    if (!context.mounted ||
                                                        _isDisposed == true)
                                                      return;
                                                    showNoConnectionMessage(
                                                      context,
                                                    );
                                                    return;
                                                  }

                                                  try {
                                                    doc.isDownloading.value =
                                                        true;
                                                    await service.downloadFile(
                                                      doc,
                                                      _cancelToken,
                                                      (received, total) {
                                                        if (!mounted ||
                                                            _isDisposed == true)
                                                          return;

                                                        doc.progress.value =
                                                            total != -1
                                                                ? received /
                                                                    total
                                                                : 0;
                                                      },
                                                    );
                                                  } catch (e) {
                                                    doc.isDownloading.value =
                                                        false;

                                                    if (!context.mounted)
                                                      return;
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Serveur indisponible',
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                  if (!mounted ||
                                                      _isDisposed == true)
                                                    return;

                                                  doc.isDownloading.value =
                                                      false;
                                                }

                                                await OpenFile.open(docPath);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color:
                                                      isDark
                                                          ? AppColors
                                                              .darkSecondarySystemBackground
                                                          : Colors.grey[100],
                                                ),
                                                height: 120,

                                                child: Row(
                                                  children: [
                                                    ValueListenableBuilder(
                                                      valueListenable:
                                                          doc.isDownloading,
                                                      builder: (
                                                        context,
                                                        isDownloading,
                                                        child,
                                                      ) {
                                                        return isDownloading
                                                            ? SizedBox(
                                                              height: 100,
                                                              width: 100,
                                                              child:
                                                                  customCircularProgress(
                                                                    doc,
                                                                  ),
                                                            )
                                                            : FutureBuilder<
                                                              Widget
                                                            >(
                                                              future:
                                                                  _buildDocumentPreview(
                                                                    doc,
                                                                    context,
                                                                  ),
                                                              builder: (
                                                                context,
                                                                snapshot,
                                                              ) {
                                                                if (snapshot
                                                                        .connectionState ==
                                                                    ConnectionState
                                                                        .waiting) {
                                                                  return const SizedBox(
                                                                    height: 100,
                                                                    width: 100,
                                                                    child: Center(
                                                                      child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else if (snapshot
                                                                        .hasError ||
                                                                    !snapshot
                                                                        .hasData) {
                                                                  logInfo(
                                                                    snapshot
                                                                        .error
                                                                        .toString(),
                                                                  );
                                                                  return const Icon(
                                                                    Icons
                                                                        .insert_drive_file,
                                                                    size: 64,
                                                                  );
                                                                } else {
                                                                  return snapshot
                                                                      .data!;
                                                                }
                                                              },
                                                            );
                                                      },
                                                    ),
                                                    SizedBox(width: 20),
                                                    Column(
                                                      // mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                maxWidth: 130,
                                                              ),
                                                          child: Text(
                                                            maxLines: 3,
                                                            fileName,
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    Align(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: PopupMenuButton<
                                                        String
                                                      >(
                                                        onSelected: (
                                                          value,
                                                        ) async {
                                                          if (value ==
                                                              'delete') {
                                                            await deleteFileIfExist(
                                                              context: context,
                                                              doc: doc,
                                                              onDeleted:
                                                                  () =>
                                                                      setState(
                                                                        () {},
                                                                      ),
                                                            );
                                                          }
                                                          /*     if (value == 'edit') {
                        final formKey = GlobalKey<FormState>();
                        TextEditingController newFileNameController =
                            TextEditingController(text: doc.filename);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 50,
                                children: [
                                  Form(
                                    key: formKey,
                                    child: TextFormField(
                                      controller: newFileNameController,
                                      decoration: InputDecoration(
                                        labelText: "Modifier titre ",
                                      ),
                                      validator:
                                          (value) =>
                                              value == null || value.isEmpty
                                                  ? "Veillez entrer un nom"
                                                  : null,
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () async {
                                      if (!await IsExistFile(doc)) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Ce fichier n'est pas télécharger",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      documentViewModel.updateDocumentName(
                                        newFileNameController.text,
                                        doc.id,
                                      );
                                      if (!context.mounted) return;
                                      Navigator.pop(context);
                                    },

                                    child: Text(
                                      "Modifier",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }*/
                                                        },
                                                        icon: Icon(
                                                          Icons.more_vert,
                                                        ),
                                                        itemBuilder: (context) {
                                                          return [
                                                            /*  PopupMenuItem(value: 'edit', child: Text("Modifier")),*/
                                                            PopupMenuItem(
                                                              value: 'delete',
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    "Supprimer",
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .delete,
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  ),
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
                                        )
                                        : GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 24,
                                            horizontal: 5,
                                          ),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,

                                                crossAxisSpacing: 0,
                                                mainAxisSpacing: 24,
                                                childAspectRatio: 1,
                                              ),
                                          itemCount: docs.length,
                                          itemBuilder: (context, index) {
                                            final doc = docs[index];
                                            final String folderName =
                                                navigationViewModel
                                                    .getFolderName(doc);

                                            return GestureDetector(
                                              onTap: () {
                                                navigationViewModel.goTo(
                                                  doc.path,
                                                );
                                              },
                                              child: ValueListenableBuilder(
                                                valueListenable:
                                                    ThemeController
                                                        .isDarkModeNotifier,
                                                builder: (
                                                  context,
                                                  isDark,
                                                  child,
                                                ) {
                                                  return CardFolder(
                                                    folder: folderName,
                                                    isDark: isDark,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Widget> _buildDocumentPreview(
    Document doc,
    BuildContext context,
  ) async {
    final isMobileScreen = Responsive.isMobile(context);
    final baseDir = await getApplicationDocumentsDirectory();
    final relativeDir = p.dirname(doc.path);
    final String fileName = p.basename(doc.path);
    final docDir = Directory(p.join(baseDir.path, "ipsl_docs", relativeDir));

    final savePath = p.join(docDir.path, fileName);
    final ext = getFileExtension(fileName);
    final fichier = File(savePath);

    if (!await fichier.exists()) {
      if (isMobileScreen) {
        return SizedBox(
          height: 100,
          width: 100,
          child: Icon(FontAwesomeIcons.arrowDown),
        );
      }
      return Icon(FontAwesomeIcons.arrowDown);
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

  Future<void> cancelDoc(Document doc) async {
    document_service.cancelDownload('Cancel by the user');
    // setState(() {});
    doc.isDownloading.value = false;
    await deleteFile(doc);
  }

  Future<bool> IsExistFile(Document doc) async {
    final path = await getSavePath(doc);
    final fichier = File(path);

    return await fichier.exists();
  }

  Future<void> deleteFile(Document doc) async {
    final path = await getSavePath(doc);
    final file = File(path);
    if (!await file.exists()) return;
    file.delete();
  }

  String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
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
            TextButton(
              child: Text("Oui"),
              onPressed: () async {
                await file.delete();
                onDeleted();
                if (!context.mounted) return;
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
}
