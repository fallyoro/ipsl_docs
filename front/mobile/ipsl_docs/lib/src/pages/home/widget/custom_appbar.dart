import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../view_models/document.dart';
import '../../upload/upload_concour_document_page.dart';
import '../../upload/upload_general_document_page.dart';
import 'breadcrums.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();

  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BreadcrumbsCustom(items: documentViewModel.currentPath),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
