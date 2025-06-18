import 'package:flutter/material.dart';
import 'package:ipsl_docs/models/document.dart';

class DocumentListView extends StatelessWidget {
  final String folderPath;
  final List<Document> documents;

  const DocumentListView({
    super.key,
    required this.folderPath,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contenu de $folderPath'),
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return ListTile(
            leading: const Icon(Icons.description),
            title: Text(doc.filename),
            subtitle: Text(doc.categorie),
           // trailing: doc.isDownload ? const Icon(Icons.check_circle) : null,
            onTap: () {
              // Action future : ouvrir fichier, prévisualiser, etc.
            },
          );
        },
      ),
    );
  }
}
