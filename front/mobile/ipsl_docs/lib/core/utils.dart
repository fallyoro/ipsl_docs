import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void logInfo(String message) {
  print('\x1B[32m$message\x1B[0m'); // Vert
}

void logError(String message) {
  print('\x1B[31m$message\x1B[0m'); // Rouge
}

void logWarning(String message) {
  print('\x1B[33m$message\x1B[0m'); // Jaune
}

Future<bool> isConnectedToInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}

void showNoConnectionMessage(BuildContext context) {
  final snackBar = SnackBar(
    content: Text(
      "Veuillez vous connecter à Internet",
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: AppColors.darkSecondarySystemBackground,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

bool isDarkModePrefer() {
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark;
}

Future<String> getSavePath(Document doc) async {
  final String fileName = p.basename(doc.path);
  final baseDir = await getApplicationDocumentsDirectory();
  final docDir = Directory(
    p.join(baseDir.path, "ipsl_docs", p.dirname(doc.path)),
  );
  if (!await docDir.exists()) {
    await docDir.create(recursive: true);
  }
  final savePath = p.join(docDir.path, fileName);
  return savePath;
}
