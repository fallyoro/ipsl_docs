import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:page_transition/page_transition.dart';

import '../../../view_models/document.dart';
import '../../../widget_tree.dart';
import '../../upload/upload_concour_document_page.dart';
import '../../upload/upload_general_document_page.dart';
import 'breadcrums.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();

  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          IconButton(
            icon: folderHomeIcon(),
            onPressed: () {
              documentViewModel.goHome();
              Navigator.of(context).pushAndRemoveUntil(
                PageTransition(
                  child: WidgetTree(),
                  type: PageTransitionType.fade,
                ),
                (route) => false,
              );
            },
          ),
          //NOTE expand make it take the reste of the space
          Flexible(
            child: BreadcrumbsCustom(items: documentViewModel.currentPath),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Widget folderHomeIcon() {
  return Stack(
    alignment: Alignment.center,
    children: [
      FaIcon(Icons.folder, size: 45, color: Colors.amber),
      FaIcon(FontAwesomeIcons.house, size: 16, color: Colors.white),
    ],
  );
}
