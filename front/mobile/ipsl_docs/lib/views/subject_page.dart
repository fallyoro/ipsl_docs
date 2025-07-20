import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/categorie_page.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';
import 'package:ipsl_docs/views/widgets/folder_home.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

class SubjectPage extends StatefulWidget {
  final String classFolder;
  final String yearFolder;

  const SubjectPage({
    super.key,
    required this.classFolder,
    required this.yearFolder,
  });

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
    late final DocumentViewModel documentViewModel;

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    documentViewModel = GetIt.I<DocumentViewModel>();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                '${widget.classFolder} / ${widget.yearFolder}',
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
          final subjectFolder =
              docs
                  .where((doc) {
                    return doc.classe == widget.classFolder &&
                        doc.year.toString() == widget.yearFolder;
                  })
                  .map((e) => e.subject)
                  .toSet()
                  .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,

              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
            ),
            itemCount: subjectFolder.length,
            itemBuilder: (context, index) {
              final folder = subjectFolder[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CategoryPage(
                            classFolder: widget.classFolder,
                            yearFolder: widget.yearFolder,
                            subjectFolder: folder,
                          ),
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
        },
      ),
    );
  }
}