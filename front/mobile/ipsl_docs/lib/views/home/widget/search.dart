import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';
import 'package:open_file/open_file.dart';

class Search extends StatelessWidget {
  const Search({super.key, required this.documents});

  final List<Document> documents;

  @override
  Widget build(BuildContext context) {
    bool isMobileDivice = Responsive.isMobileDevice(context);
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
              String docPath = await getSavePath(doc);
              if (await isExistFile(docPath) == false) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Veillez d'abord telecharger ce fichier"),
                  ),
                );
                return;
              }
              final ext = getFileExtension(doc.filename);
              if (ext == 'wxmx' && isMobileDivice) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Veillez ouvrir ce fichier avec votre pc"),
                  ),
                );
                return;
              }
              await OpenFile.open(docPath);
              // docsFilter
              // Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: DocumentListView(documents: documents)))
            },
          );
        });
      },
      barBackgroundColor: WidgetStateProperty.all(Colors.white),
      barElevation: WidgetStateProperty.all(0.5),
      barHintText: "Chercher",
    );
  }
}
