import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../models/document.dart';

Future<Widget> buildDocumentPreview(
  BuildContext context, [
  String? relativePath,
  String? completePath,
]) async {
  String path;
  if (completePath != null) {
    path = completePath;
  } else {
    final baseDir = await getApplicationDocumentsDirectory();
    final docDir = Directory(
      p.join(baseDir.path, "ipsl_docs", p.dirname(relativePath!)),
    );
    final String name = p.basename(relativePath);
    path = p.join(docDir.path, name);
  }
  final fichier = File(path);
  final String extension = path.split('.').last.toLowerCase();

  if (!await fichier.exists()) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Icon(FontAwesomeIcons.arrowDown),
    );
  }
  if (['jpg', 'jpeg', 'png'].contains(extension)) {
    final file = File(path);
    if (!file.existsSync()) {
      return Icon(FontAwesomeIcons.image);
    }
    return Image.file(
      file,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  } else if (extension == 'pdf') {
    final pdfDocument = await PdfDocument.openFile(path);
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
  } else if (extension == 'wxmx') {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1000),
      child: Image.asset('assets/images/logo_maxima.png', height: 100),
    );
  }

  // If we get here there's definaly an error
  return Icon(Icons.error);
}
