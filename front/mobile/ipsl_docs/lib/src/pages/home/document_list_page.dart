import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/home/widget/custom_appbar.dart';
import 'package:ipsl_docs/src/pages/home/widget/document_list.dart';
import 'package:ipsl_docs/src/view_models/directory_node.dart';
import 'package:ipsl_docs/src/view_models/document.dart';

class DocumentListPage extends StatelessWidget {
  final DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();
  final DirectoryNode node;
  DocumentListPage({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        documentViewModel.goBack();
        return true;
      },
      child: Scaffold(
        appBar: CustomAppBar(),
        body: DocumentListWidget(documents: node.documents),
      ),
    );
  }
}
