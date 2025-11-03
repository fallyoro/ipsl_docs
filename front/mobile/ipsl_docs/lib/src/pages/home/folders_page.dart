import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/home/widget/custom_appbar.dart';
import 'package:ipsl_docs/src/pages/home/widget/directory_gird.dart';
import 'package:ipsl_docs/src/view_models/directory_node.dart';
import 'package:ipsl_docs/src/view_models/document.dart';

class FoldersPage extends StatelessWidget {
  final DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();
  final List<DirectoryNode> subDirectories;
  FoldersPage({super.key, required this.subDirectories});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        documentViewModel.goBack();
      },

      child: Scaffold(
        appBar: CustomAppBar(),

        body: DirectoryGrid(subDirectories: subDirectories),
      ),
    );
  }
}
