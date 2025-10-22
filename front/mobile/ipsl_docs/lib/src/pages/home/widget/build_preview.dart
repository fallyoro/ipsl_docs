import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../models/document.dart';

Future<Widget> buildDocumentPreview(Document doc, BuildContext context) async {
  final baseDir = await getApplicationDocumentsDirectory();
  // final docDir = Directory(p.join(baseDir.path, "ipsl_docs", doc.path));
  final docDir = Directory(
    p.join(baseDir.path, "ipsl_docs", p.dirname(doc.path)),
  );
  final savePath = p.join(docDir.path, doc.name);
  final ext = getFileExtension(doc.name);
  final fichier = File(savePath);

  if (!await fichier.exists()) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Icon(FontAwesomeIcons.arrowDown),
    );

    //  return Icon(FontAwesomeIcons.arrowDown);
  }

  if (['jpg', 'jpeg', 'png'].contains(ext)) {
    final file = File(savePath);
    if (!file.existsSync()) {
      return Icon(FontAwesomeIcons.image);
    }
    return Image.file(
      file,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  } else if (ext == 'pdf') {
    final pdfDocument = await PdfDocument.openFile(savePath);
    return SizedBox(
      width: 100,
      height: 100,
      child: PdfPageView(
        document: pdfDocument,
        pageNumber: 1,
        alignment: Alignment.center,
        pageSizeCallback: (widgetSize, page) {
          // Calcule un aperçu qui tient dans le carré tout en gardant le ratio
          final pageRatio = page.height / page.width;
          double previewWidth = widgetSize.width;
          double previewHeight = previewWidth * pageRatio;

          if (previewHeight > widgetSize.height) {
            previewHeight = widgetSize.height;
            previewWidth = previewHeight / pageRatio;
          }

          return Size(previewWidth, previewHeight);
        },
      ),
    );
  } else if (ext == 'wxmx') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1000),
      child: Image.asset('assets/images/logo_maxima.png', height: 100),
    );
  }

  // If we get here there's definaly an error
  return Icon(Icons.error);
}

String getFileExtension(String fileName) {
  return fileName.split('.').last.toLowerCase();
}
