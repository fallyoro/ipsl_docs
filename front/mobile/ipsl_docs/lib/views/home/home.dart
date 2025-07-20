import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/year_folder_page.dart';
import 'package:ipsl_docs/views/home/widget/search.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final UserViewModel userViewModel;
  late final DocumentViewModel documentViewModel;
  bool isLoading = false;
  bool _hasFetched = false;
  String errorMessage = "";

  String userName = "hello";
  Responsive responsive = Responsive();

  @override
  void initState() {
    super.initState();
    userViewModel = GetIt.instance<UserViewModel>();
    documentViewModel = GetIt.I<DocumentViewModel>();
    var userData = SQLiteService.instance.getUser();
    String userNameq = userData!['user_name'];
    setState(() {
      userName = userNameq;
    });
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final bool isConnected = await isConnectedToInternet();
    try {
      if (isConnected & !_hasFetched) {
        final data = await document_service.fetchDocuments();
        _hasFetched = true;
        SQLiteService.instance.insertAllDoc(data);
        documentViewModel.loadDocuments();
      }
    } catch (e) {
      errorMessage = 'Erreur lors du chargement : $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentsList = documentViewModel.documents.value;
    double screenWidth = MediaQuery.of(context).size.width;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<Document>>(
      valueListenable: documentViewModel.documents,
      builder: (context, docs, _) {
        final classe =
            documentViewModel.getClasseFolders()
              ..sort((a, b) => a.compareTo(b));

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,

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
              Search(documents: documentsList),
              builFolders(classe, screenWidth),
            ],
          ),
        );
      },
    );
  }

  GridView builFolders(List<String> folders, double screenWidth) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,

        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => YearPage(classe: folder)),
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
}
