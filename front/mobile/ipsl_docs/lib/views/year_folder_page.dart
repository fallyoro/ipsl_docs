import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';
import 'package:ipsl_docs/views/subject_page.dart';
import 'package:ipsl_docs/views/widgets/folder_home.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

class YearPage extends StatefulWidget {
  final String classe;
  const YearPage({super.key, required this.classe});

  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
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
                widget.classe,
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
          final yearFolders =
              docs
                  .where((doc) => doc.classe == widget.classe)
                  .map((doc) => doc.year)
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
            itemCount: yearFolders.length,
            itemBuilder: (context, index) {
              final year = yearFolders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => SubjectPage(
                            classFolder: widget.classe,
                            yearFolder: year.toString(),
                          ),
                    ),
                  );
                },
                child: CardFolder(
                  screenWidth: screenWidth,
                  folder: year.toString(),
                  isDark: ThemeController.isDarkModeNotifier.value,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
