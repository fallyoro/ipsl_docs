/*import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/pages/widgets/documents_list_view.dart';

class Search extends StatelessWidget {
  const Search({super.key, required this.documents});

  final List<Document> documents;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      constraints: BoxConstraints(maxWidth: 600, minHeight: 55),
      suggestionsBuilder: (context, controller) {
        final input = controller.text.toLowerCase();
        final seen = <String>{};
        final results =
            documents
                .where((doc) => doc.filename.toLowerCase().contains(input))
                .where(
                  (doc) => seen.add(doc.filename),
                ) // garde seulement le premier doc avec ce nom
                .toList();

        return results.map((doc) {
          return ListTile(
            title: Text(doc.filename),
            onTap: () async {
              FocusScope.of(context).unfocus();

              controller.text = doc.filename;

              List<Document> documentsListView =
                  documents.where((_doc) {
                    return _doc.classe == doc.classe &&
                        _doc.year == doc.year &&
                        _doc.subject == doc.subject &&
                        _doc.categorie == doc.categorie;
                  }).toList();
              logInfo(documentsListView.length.toString());
              logInfo(results.first.categorie);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          DocumentListView(documents: documentsListView),
                ),
              );
              controller.text = '';
            },
          );
        });
      },
      barBackgroundColor: WidgetStateProperty.all(Colors.white),
      barElevation: WidgetStateProperty.all(0.5),
      barHintText: "Chercher",
      barTextStyle: WidgetStatePropertyAll(
        const TextStyle(color: Colors.black),
      ),
    );
  }
}
*/
