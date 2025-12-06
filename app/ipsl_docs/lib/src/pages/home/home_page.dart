import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/theme_controller.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/pages/home/widget/custom_curve.dart';
import 'package:ipsl_docs/src/pages/home/widget/directory_gird.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:url_launcher/url_launcher.dart';

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
            fontSize: 26,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primaryColor,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryColor),
              currentAccountPicture:
                  userViewModel.userNotifier.value?.pictureUrl != null
                      ? CachedNetworkImage(
                        height: 100,
                        imageUrl: userViewModel.userNotifier.value!.pictureUrl!
                            .replaceAll('s96-c', 's400-c'),
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: imageProvider,
                          );
                        },
                      )
                      : SizedBox.shrink(),
              accountName: Text(
                userViewModel.userNotifier.value!.userName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                userViewModel.userNotifier.value!.email,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: Text(
                "Theme",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading:
                  isDark
                      ? Icon(Icons.light_mode, color: Colors.white)
                      : const Icon(Icons.dark_mode),
              onTap: () {
                ThemeController.toggleTheme();
              },
            ),
            ListTile(
              leading: Image.asset(
                "assets/images/paypal.png",
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
              title: Text(
                "Faire un don PayPal",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                await openUrl("https://www.paypal.com/paypalme/fallyorro");
              },
            ),
            ListTile(
              leading: FaIcon(FontAwesomeIcons.github, size: 32),
              title: Text(
                "Code source",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                await openUrl("https://github.com/fallyoro/ipsl_docs");
              },
            ),
          ],
        ),
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
                      ValueListenableBuilder(
                        valueListenable: userViewModel.userNotifier,
                        builder: (context, user, child) {
                          return Text.rich(
                            TextSpan(
                              text: 'Salut 👋, ',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
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
                        },
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: documentViewModel.root,
                builder: (context, root, child) {
                  if (root!.subDirectories.isEmpty) {
                    return Center(child: Text("Vous n'avez aucun document"));
                  }

                  return DirectoryGrid(subDirectories: root.subDirectories);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /*
  TODO put this in the viewmodel
  Please if you see this put it in the viewmodel and rewrite it with dartz. I'm tired
*/
  Future<void> _fetchDocuments() async {
    logInfo("Fetching documents...");
    final bool isConnected = await isConnectedToInternet();
    try {
      if (isConnected) {
        await documentViewModel.syncDocumentFromServer();
      }
    } catch (e) {
      String errorMessage = 'Erreur lors du chargement : $e';
      logInfo(errorMessage);
    }

    await documentViewModel.loadDocuments();
  }
}
