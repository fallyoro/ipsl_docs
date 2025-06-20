import 'package:flutter/material.dart';
import 'package:ipsl_docs/services/document.dart';

class ThemeController {
  ThemeController._(); // Constructeur privé

  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
  static void toggleTheme() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }
}

final document_service = DocumentServive();
