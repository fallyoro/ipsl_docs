import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/widgets/folder_home.dart';
import 'package:ipsl_docs/views/year_folder_page.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

final viewModel = GetIt.I<DocumentViewModel>();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  String userName = "hello";
  Responsive responsive = Responsive();
  final files = [];

  @override
  void initState() {
    super.initState();
    var userData = SQLiteService.instance.getUser();
    String userNameq = userData['user_name'];
    setState(() {
      userName = userNameq;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<Document>>(
      valueListenable: viewModel.documents,
      builder: (context, docs, _) {
        final classe = viewModel.getClasseFolders();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              Text.rich(
                TextSpan(
                  text: 'Salut, ',
                  style: TextStyle(fontSize: 22),
                  children: [
                    TextSpan(
                      text: userName,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SearchAnchor.bar(
                constraints: BoxConstraints(maxWidth: 600, minHeight: 55),
                suggestionsBuilder: (context, controller) {
                  final input = controller.text.toLowerCase();
                  final results =
                      files
                          .where(
                            (filename) =>
                                filename.toLowerCase().contains(input),
                          )
                          .toList();

                  return results.map((filename) {
                    return ListTile(
                      title: Text(filename),
                      onTap: () {
                        controller.text = filename;
                        //SearchAnchor.of(context).close();
                        //FocusScope.of(context).unfocus();
                      },
                    );
                  });
                },
                barBackgroundColor: WidgetStateProperty.all(
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSecondarySystemBackground
                      : Colors.white,
                ),
                barElevation: WidgetStateProperty.all(0.5),
                barHintText: "chercher",
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,

                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: classe.length,
                itemBuilder: (context, index) {
                  final folder = classe[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => YearPage(classe: folder),
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
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardFolder extends StatefulWidget {
  const CardFolder({
    super.key,
    required this.screenWidth,
    required this.folder,
    required this.isDark,
  });

  final double screenWidth;
  final String folder;
  final bool isDark;

  @override
  State<CardFolder> createState() => _CardFolderState();
}

class _CardFolderState extends State<CardFolder> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    if (widget.isDark) {
      backgroundColor =
          isHover
              ? AppColors.darkTertiarySystemBackground
              : AppColors.darkSecondarySystemBackground;
    } else {
      backgroundColor =
          isHover
              ? AppColors.lightTertiarySystemBackground
              : AppColors.lightSecondarySystemBackground;
    }
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: Card(
        elevation: widget.isDark ? 0 : 2,

        color: backgroundColor,

        // elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              size: widget.screenWidth < 600 ? 60 : 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              widget.folder,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.screenWidth < 600 ? 14 : 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        valueListenable: viewModel.documents,
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
        valueListenable: viewModel.documents,
        builder: (context, docs, _) {
          final categoryFolder =
              docs
                  .where((doc) {
                    return doc.classe == widget.classFolder &&
                        doc.year.toString() == widget.yearFolder &&
                        doc.subject == widget.subjectFolder;
                  })
                  .map((doc) => doc.categorie)
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
            itemCount: categoryFolder.length,
            itemBuilder: (context, index) {
              final folder = categoryFolder[index];
              final documents =
                  docs.where((doc) {
                    return doc.classe == widget.classFolder &&
                        doc.year.toString() == widget.yearFolder &&
                        doc.subject == widget.subjectFolder &&
                        doc.categorie == folder;
                  }).toList();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentListView(documents: documents),
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
