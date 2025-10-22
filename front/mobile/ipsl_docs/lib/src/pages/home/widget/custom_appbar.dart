import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../view_models/document.dart';
import '../../upload_concour_document_page.dart';
import '../../upload_general_document_page.dart';
import 'breadcrums.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();
  final BuildContext ctx;

  CustomAppBar({
    super.key,
    required this.ctx,
  });

  @override
  bool get isDark => Theme.of(ctx).brightness == Brightness.dark;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:
               BreadcrumbsCustom(items: documentViewModel.currentPath)
      ,

      actions: [
        documentViewModel.isInConcours
            ? IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadConcoursDocumentPage(),
                  ),
                );
              },
              icon: Icon(Icons.add, size: 35),
            )
            : documentViewModel.isInGeneral
            ? IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadGeneralDocumentPage(),
                  ),
                );
              },
              icon: Icon(Icons.add, size: 35),
            )
            : Container(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
