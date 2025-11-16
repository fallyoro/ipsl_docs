import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/build_document_preview.dart';
import '../../../models/document.dart';

FutureBuilder<Widget> previewWidget({
  required BuildContext context,
  String? localPath,
  String? relativePath,
}) {
  //TODO definir buildDocumentPreview avec des {} au lieu de [] pour rendre obligatoire la fait de preciser le nom des parametre. j'ai la flemme.
  return FutureBuilder<Widget>(
    future:
        relativePath != null
            ? buildDocumentPreview(context, relativePath)
            : buildDocumentPreview(context, localPath),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          height: 100,
          width: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      } else if (snapshot.hasError || !snapshot.hasData) {
        // log l’erreur si tu as une méthode
        return const Icon(Icons.insert_drive_file, size: 64);
      } else {
        return snapshot.data!;
      }
    },
  );
}
