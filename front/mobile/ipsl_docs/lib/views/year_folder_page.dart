import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/views/home.dart';
import 'package:ipsl_docs/views/widgets/folder_home.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

class YearPage extends StatelessWidget {
  final String classe;
  const YearPage({super.key, required this.classe});

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
                classe,
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
        valueListenable: viewModel.documents,
        builder: (context, docs, _) {
          final yearFolders =
              docs
                  .where((doc) => doc.classe == classe)
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
                            classFolder: classe,
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
