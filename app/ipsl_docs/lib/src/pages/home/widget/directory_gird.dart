import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/pages/home/document_list_page.dart';
import 'package:ipsl_docs/src/pages/home/folders_page.dart';

import '../../../view_models/directory_node.dart';
import '../../../view_models/document.dart';
import 'card_folder.dart';

class DirectoryGrid extends StatefulWidget {
  final List<DirectoryNode> subDirectories;

  const DirectoryGrid({super.key, required this.subDirectories});

  @override
  State<DirectoryGrid> createState() => _DirectoryGridState();
}

class _DirectoryGridState extends State<DirectoryGrid> {
  late final DocumentViewModel documentViewModel;

  @override
  void initState() {
    super.initState();
    documentViewModel = GetIt.I<DocumentViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 0,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: widget.subDirectories.length,
      itemBuilder: (context, index) {
        final dirNode = widget.subDirectories[index];
        return CardFolder(
          folder: dirNode.name,
          onTap: () {
            documentViewModel.openDirectory(dirNode);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return dirNode.hasSubdirectories
                      ? FoldersPage(subDirectories: dirNode.subDirectories)
                      : DocumentListPage(node: dirNode);
                },
              ),
            );
          },
        );
      },
    );
  }
}
