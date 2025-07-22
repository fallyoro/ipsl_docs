import 'package:get_it/get_it.dart';
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
import 'package:ipsl_docs/views/home/widget/navigation_drawer.dart';
import 'package:ipsl_docs/views/home/widget/upload_form_document.dart';
import 'package:ipsl_docs/views/year_folder_page.dart';
import 'package:ipsl_docs/views/home/widget/search.dart';
import 'package:ipsl_docs/views/home/widget/card_folder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

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
    final isMobile = Responsive.isMobile(context);
    final isDestop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    double screenWidth = MediaQuery.of(context).size.width;

    final documentsList = documentViewModel.documents.value;

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<Document>>(
      valueListenable: documentViewModel.documents,
      builder: (context, docs, _) {
        final classe =
            documentViewModel.getClasseFolders()
              ..sort((a, b) => a.compareTo(b));

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              isMobile ? builBottomSheetUpload(context) : buildDialog(context);
            },
            child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
          ),
          backgroundColor:
              Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSystemBackground
                  : AppColors.primaryColor,
          drawer: (isMobile) ? buildDrawer() : null,

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
                            Container(
                              padding: EdgeInsets.only(
                                bottom: 90,
                                left: 20,
                                right: 20,
                              ),
                              color:
                                  isDark
                                      ? AppColors.darkSystemBackground
                                      : AppColors.primaryColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: userName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Search(documents: documentsList),
                                ],
                              ),
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
                                          ? AppColors.darkSystemBackground
                                          : AppColors.lightSystemBackground,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                ),
                                child: builFolders(classe, screenWidth),
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

  Future<dynamic> buildDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Uploader un document"),
            content: SingleChildScrollView(
              child: UploadFormContent(onSuccess: () => Navigator.pop(context)),
            ),
          ),
    );
  }

  GridView builFolders(List<String> folders, double screenWidth) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,

        crossAxisSpacing: 0,
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
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: YearPage(classe: folder),
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
}

/* GridView builFolders(List<String> folders, double screenWidth) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,

        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 1.1,
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
                child: YearPage(classe: folder),
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
  }*/
