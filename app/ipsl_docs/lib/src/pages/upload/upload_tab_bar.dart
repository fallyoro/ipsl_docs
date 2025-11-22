import 'package:flutter/material.dart';
import 'package:ipsl_docs/src/pages/upload/upload_specifique_document_page.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/upload/upload_general_document_page.dart';

final List<Widget> _pages = [
  UploadSpecifiqueDocumentPage(),
  UploadGeneralDocumentPage(),
  UploadConcoursDocumentPage(),
];

class UploadTabBar extends StatelessWidget {
  const UploadTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _pages.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Partager un document"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Specifique"),
              Tab(text: "Général"),
              Tab(text: "Concours"),
            ],
          ),
        ),
        body: TabBarView(children: _pages),
      ),
    );
  }
}
