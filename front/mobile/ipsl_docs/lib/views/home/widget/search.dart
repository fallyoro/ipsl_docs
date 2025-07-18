


import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';
import 'package:open_file/open_file.dart';

class Search extends StatelessWidget {
  const Search({
    super.key,
    required this.documents,
  });

  final List<Document> documents;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      constraints: BoxConstraints(maxWidth: 600, minHeight: 55),
      suggestionsBuilder: (context, controller) {
        final input = controller.text.toLowerCase();
        final results =
            documents
                .where(
                  (doc) => doc.filename.toLowerCase().contains(input),
                )
                .toList();
    
        return results.map((doc) {
          return ListTile(
            title: Text(doc.filename),
            onTap: () async {
              controller.text = doc.filename;
              String docPath = await getSavePath(doc);
              if (await isExistFile(docPath) == false) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Veillez d'abord telecharger ce fichier",
                    ),
                  ),
                );
                return;
              }
              await OpenFile.open(docPath);
            },
          );
        });
      },
      barBackgroundColor: WidgetStateProperty.all(
        Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSecondarySystemBackground
            : Colors.white,
      ),
      barElevation: WidgetStateProperty.all(0.5),
      barHintText: "Chercher",
    );
  }
}
