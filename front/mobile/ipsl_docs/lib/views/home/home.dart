import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/global.dart';
import 'package:ipsl_docs/view_models/directory_node.dart';
import 'package:ipsl_docs/views/home/widget/directory_gird.dart';
import 'package:ipsl_docs/views/home/widget/document_list.dart';
import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home/widget/bottom_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database.dart';
import '../../services/document.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late UserViewModel userViewModel = GetIt.instance<UserViewModel>();
  late DocumentViewModel documentViewModel = GetIt.instance<DocumentViewModel>();
  bool isLoading = false;
  bool _hasFetched = false;
  String errorMessage = "";

  DocumentServive service = DocumentServive();
  bool _isDisposed = false;
  late CancelToken _cancelToken;

  // String userName = "hello";
  Responsive responsive = Responsive();

  @override
  void initState() {
    super.initState();
    userViewModel = GetIt.instance<UserViewModel>();
    //userViewModel.getUser();
    documentViewModel = GetIt.instance<DocumentViewModel>();
  _fetchDocuments();
  }

  Future<bool> _onWillPop() async {
    if (documentViewModel.canGoBack) {
      documentViewModel.goBack();
      return false; // annule le pop de la route: on reste dans la page
    }
    return true; // laisse l'app faire le pop (quitter la page/app)
  }

  Future<void> _fetchDocuments() async {
    final bool isConnected = await isConnectedToInternet();
    try {
      if (isConnected && _hasFetched == false ) {
        //TODO remove the object document_service from ToggleTheme
        final data = await document_service.fetchDocuments();

        DatabaseHelper.instance.deleteAlldoc();
        DatabaseHelper.instance.insertAllDoc(data);
        documentViewModel.loadDocuments();

        _hasFetched = true;
      }
    } catch (e) {
      errorMessage = 'Erreur lors du chargement : $e';
      logInfo(errorMessage);
    }

    documentViewModel.loadDocuments();
    _hasFetched = true;
  }

  @override
  Widget build(BuildContext context) {
    //    final documentsList = documentViewModel.documents.value;
    // final documentClass = documentsList.map((d) => d.classe).toSet().toList();

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ValueListenableBuilder<DirectoryNode?>(
      valueListenable: documentViewModel.currentDirectory,
      builder: (context, current, child) {
        if (current == null) {
          return Center(child: Text("Aucun document trouve"));
        }
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              builBottomSheetUpload(context);
            },
            child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
          ),
          appBar: CustomAppBar(
            ctx: context,
            title: current.name,
            canGoBack: documentViewModel.canGoBackNotifier.value,
            onBackPressed: () {
              documentViewModel.goBack();
            },
            documentViewModel: documentViewModel,
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                !documentViewModel.canGoBackNotifier.value
                    ? ClipPath(
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
                                text: 'Bienvenue 👋, ',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        userViewModel
                                            .userNotifier
                                            .value!
                                            .userName,
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
                    )
                    : Container(),
                current.hasSubdirectories
                    ? DirectoryGrid(
                      subDirectories: current.subDirectories,
                      documentViewModel: documentViewModel,
                    )
                    : DocumentListWidget(service: service),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canGoBack;
  final VoidCallback onBackPressed;
  final DocumentViewModel documentViewModel;
  final BuildContext ctx;

  CustomAppBar({
    Key? key,
    required this.title,
    required this.canGoBack,
    required this.onBackPressed,
    required this.documentViewModel,
    required this.ctx,
  }) : super(key: key);

  @override
  bool get isDark => Theme.of(ctx).brightness == Brightness.dark;
  Widget build(BuildContext context) {
    return AppBar(
      title:
          canGoBack
              ? BreadcrumbsCustom(items: documentViewModel.currentPath)
              : Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
     backgroundColor: canGoBack ? (isDark ? AppColors.darkSecondarySystemBackground: Colors.white) : AppColors.primaryColor,
      leading:
          canGoBack
              ? IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back),
              )
              : null,
      actions: [
        !canGoBack
            ? IconButton(
              onPressed: () => ThemeController.toggleTheme(),

              icon:
                  isDark
                      ? const Icon(Icons.light_mode, color: Colors.white)
                      : const Icon(Icons.dark_mode, color: Colors.white),
            )
            : Container(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomCurvedEdges extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    final firstCurve = Offset(0, size.height - 20);
    final lastCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(
      firstCurve.dx,
      firstCurve.dy,
      lastCurve.dx,
      lastCurve.dy,
    );

    final secondFirstCurve = Offset(0, size.height - 20);
    final secondLastCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    final thirdFirstCurve = Offset(size.width, size.height - 20);
    final thirdLastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(
      thirdFirstCurve.dx,
      thirdFirstCurve.dy,
      thirdLastCurve.dx,
      thirdLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BreadcrumbsCustom extends StatelessWidget {
  final List<String> items;
  final void Function(int index)? onTap;
  final TextStyle? textStyle;
  final TextStyle? lastItemStyle;
  final Widget separator;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const BreadcrumbsCustom({
    Key? key,
    required this.items,
    this.onTap,
    this.textStyle,
    this.lastItemStyle,
    this.separator = const Icon(
      Icons.chevron_right,
      size: 16,
      color: Colors.grey,
    ),
    this.spacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Si pas ou un seul élément, on affiche juste le dernier (ou rien)
    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    final defaultStyle =
        textStyle ?? TextStyle(color: Colors.black, fontSize: 16);
    final defaultLastStyle =
        lastItemStyle ??
        TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );

    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: padding,
        child: Row(
          children: List.generate(items.length * 2 - 1, (index) {
            // on intercale séparateur entre les items
            if (index.isEven) {
              int itemIndex = index ~/ 2;
              bool isLast = itemIndex == items.length - 1;
              return GestureDetector(
                onTap:
                    (!isLast && onTap != null) ? () => onTap!(itemIndex) : null,
                child: Text(
                  items[itemIndex],
                  style: isLast ? defaultLastStyle : defaultStyle,
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: separator,
              );
            }
          }),
        ),
      ),
    );
  }
}
