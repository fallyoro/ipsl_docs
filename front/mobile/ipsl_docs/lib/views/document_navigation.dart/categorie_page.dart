import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';
import 'package:ipsl_docs/views/widgets/folder_home.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

class CategoryPage extends StatefulWidget {
  final String classFolder;
  final String yearFolder;
  final String subjectFolder;

  const CategoryPage({
    super.key,
    required this.classFolder,
    required this.yearFolder,
    required this.subjectFolder,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final DocumentViewModel documentViewModel;

  @override
  void initState() {
    super.initState();
    documentViewModel = GetIt.I<DocumentViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isMobileDevice = Responsive.isMobileDevice(context);
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
                '${widget.classFolder} / ${widget.yearFolder} / ${widget.subjectFolder}',
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

      body: ValueListenableBuilder<List<Document>>(
        valueListenable: documentViewModel.documents,
        builder: (context, docs, _) {
          final categoryFolders =
              docs
                  .where((doc) {
                    return doc.classe == widget.classFolder &&
                        doc.year == widget.yearFolder &&
                        doc.subject == widget.subjectFolder;
                  })
                  .map((doc) => doc.categorie)
                  .toSet()
                  .toList();

          return isMobileDevice
              ? buildCategoryFoldersOnMobile(
                categoryFolders,
                docs,
                widget.classFolder,
                screenWidth,
              )
              : buildCategoryFoldersOnDesktop(
                categoryFolders,
                docs,
                widget.classFolder,
                screenWidth,
              );
        },
      ),
    );
  }

  GridView buildCategoryFoldersOnMobile(
    List<String> categoryFolders,
    List<Document> docs,
    String classe,
    double screenWidth,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 0,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: categoryFolders.length,
      itemBuilder: (context, index) {
        final folder = categoryFolders[index];
        final documents =
            docs.where((doc) {
              return doc.classe == widget.classFolder &&
                  doc.year == widget.yearFolder &&
                  doc.subject == widget.subjectFolder &&
                  doc.categorie == folder;
            }).toList();
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: DocumentListView(documents: documents),
                duration: Duration(milliseconds: 10),
              ),
            );
          },
          child: ValueListenableBuilder(
            valueListenable: ThemeController.isDarkModeNotifier,
            builder: (context, isDark, child) {
              return CardFolder(
                screenWidth: screenWidth,
                folder: folder,
                isDark: ThemeController.isDarkModeNotifier.value,
              );
            },
          ),
        );
      },
    );
  }

  GridView buildCategoryFoldersOnDesktop(
    List<String> categoryFolders,
    List<Document> docs,
    String classe,
    double screenWidth,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        crossAxisSpacing: 20,
        mainAxisSpacing: 0,
        childAspectRatio: 1.1,
      ),
      itemCount: categoryFolders.length,
      itemBuilder: (context, index) {
        final subject = categoryFolders[index];
        final documents =
            docs.where((doc) {
              return doc.classe == widget.classFolder &&
                  doc.year == widget.yearFolder &&
                  doc.subject == widget.subjectFolder &&
                  doc.categorie == subject;
            }).toList();
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: DocumentListView(documents: documents),
                duration: Duration(milliseconds: 10),
              ),
            );
          },
          child: CardFolder(
            screenWidth: screenWidth,
            folder: subject,
            isDark: ThemeController.isDarkModeNotifier.value,
          ),
        );
      },
    );
  }
}


/*
GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,

              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
            ),
            itemCount: categoryFolder.length,
            itemBuilder: (context, index) {
              final folder = categoryFolder[index];
              final documents =
                  docs.where((doc) {
                    return doc.classe == widget.classFolder &&
                        doc.year == widget.yearFolder &&
                        doc.subject == widget.subjectFolder &&
                        doc.categorie == folder;
                  }).toList();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: DocumentListView(documents: documents),
                      duration: Duration(milliseconds: 210),
                    ),
                  );
                },
                child: ValueListenableBuilder(
                  valueListenable: ThemeController.isDarkModeNotifier,
                  builder: (context, isDark, child) {
                    return CardFolder(
                      screenWidth: screenWidth,
                      folder: folder,
                      isDark: ThemeController.isDarkModeNotifier.value,
                    );
                  },
                ),
              );
            },
          );*/