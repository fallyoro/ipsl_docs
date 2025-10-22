import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/home/widget/custom_curve.dart';
import 'package:ipsl_docs/src/pages/home/widget/directory_gird.dart';
import 'package:flutter/material.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/core/notifiers.dart';
import 'package:ipsl_docs/src/core/Responsive.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/pages/home/widget/bottom_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/document.dart';
//import 'home.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  late UserViewModel userViewModel = GetIt.instance<UserViewModel>();
  late DocumentViewModel documentViewModel =
      GetIt.instance<DocumentViewModel>();
  bool isLoading = false;
  String errorMessage = "";
  DocumentService service = DocumentService();
  //late CancelToken _cancelToken;

  Responsive responsive = Responsive();

  @override
  void initState() {
    super.initState();
    userViewModel = GetIt.instance<UserViewModel>();
    documentViewModel = GetIt.instance<DocumentViewModel>();
    _fetchDocuments();
  }


  Future<void> _fetchDocuments() async {
    final bool isConnected = await isConnectedToInternet();
    try {
      if (isConnected) {
        await documentViewModel.syncDocumentFromServer();
      }
    } catch (e) {
      errorMessage = 'Erreur lors du chargement : $e';
      logInfo(errorMessage);
    }

    await documentViewModel.loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
        return Scaffold(
          floatingActionButton:
                   FloatingActionButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    onPressed: () {
                      builBottomSheetUpload(context);
                    },
                    child: const Icon(
                      FontAwesomeIcons.plus,
                      color: Colors.white,
                    ),
                  )
          ,
          appBar: AppBar(
            title: Text(
              "IPSL DOCS",
              style: TextStyle(
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
              )
            ],
          ),
          body: SingleChildScrollView(
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
                        Text.rich(
                          TextSpan(
                            text: 'Salut 👋, ',
                            style: TextStyle(fontSize: 22, color: Colors.white),
                            children: [
                              TextSpan(
                                text:
                                    userViewModel.userNotifier.value!.userName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        //Search(documents: documentsList),
                      ],
                    ),
                  ),
                ),
                DirectoryGrid(
                  subDirectories: documentViewModel.root.value!.subDirectories,
                ),
              ],
            ),
          ),
        );
  }
}
