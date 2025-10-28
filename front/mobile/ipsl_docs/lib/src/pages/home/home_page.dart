import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/src/pages/home/widget/custom_curve.dart';
import 'package:ipsl_docs/src/pages/home/widget/directory_gird.dart';
import 'package:flutter/material.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/core/theme_controller.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import '../../services/document.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserViewModel userViewModel = GetIt.instance<UserViewModel>();
  DocumentViewModel documentViewModel = GetIt.instance<DocumentViewModel>();
  bool isLoading = false;
  DocumentService service = DocumentService();

  //TODO put this in the viewmodel
  Future<void> _fetchDocuments() async {
    logInfo("Fetching documents...");
    final bool isConnected = await isConnectedToInternet();
    try {
      if (isConnected) {
        await documentViewModel.syncDocumentFromServer();
      }
    } catch (e) {
   String   errorMessage = 'Erreur lors du chargement : $e';
      logInfo(errorMessage);
    }

    await documentViewModel.loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "IPSL DOCS",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            onPressed: () => ThemeController.toggleTheme(),
            icon:
                isDark
                    ? const Icon(Icons.light_mode, color: Colors.white)
                    : const Icon(Icons.dark_mode, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: _fetchDocuments,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), //Make the refresh indicator working
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipPath(
                clipper: CustomCurvedEdges(),
                child: Container(
                  color: AppColors.primaryColor,
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    top: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //Search(documents: documentsList),
                      ValueListenableBuilder(valueListenable: userViewModel.userNotifier, builder: (context, user, child) {
                        return
                          Text.rich(
                            TextSpan(
                              text: 'Salut 👋, ',
                              style: TextStyle(fontSize: 22, color: Colors.white),
                              children: [
                                TextSpan(
                                  text: user!.userName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                      },)
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(valueListenable: documentViewModel.root, builder: (context, root, child) {
                return
                  DirectoryGrid(
                    subDirectories: root!.subDirectories
                  );
              },)
            ],
          ),
        ),
      ),
    );
  }
}
