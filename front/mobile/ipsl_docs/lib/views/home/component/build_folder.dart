/*import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';
import 'package:page_transition/page_transition.dart';

GridView buildFoldersOnMobile(
  List<String> folders,
  // List<Document> documents,
  double screenWidth,
  Widget Function(String folder) pageBuilder,
) {
  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 5),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,

      crossAxisSpacing: 0,
      mainAxisSpacing: 24,
      childAspectRatio: 1,
    ),
    itemCount: folders.length,
    itemBuilder: (context, index) {
      final folder = folders[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: pageBuilder(folder),
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
              isDark: isDark,
            );
          },
        ),
      );
    },
  );
}

GridView builFoldersOnDesktop(
  List<String> folders,
  // List<Document> documents,
  double screenWidth,
  Widget Function(String folder) pageBuilder,
) {
  return GridView.builder(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(0),
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 180,

      crossAxisSpacing: 20,
      mainAxisSpacing: 0,
      childAspectRatio: 1,
    ),
    itemCount: folders.length,
    itemBuilder: (context, index) {
      final folder = folders[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: pageBuilder(folder),
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
              isDark: isDark,
            );
          },
        ),
      );
    },
  );
}
*/
