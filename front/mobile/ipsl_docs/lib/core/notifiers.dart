import 'package:flutter/material.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/stokage_service.dart';

class ThemeController {
  ThemeController._();

  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(true);
  static void toggleTheme() async {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
    await StorageService.setBool("isDark", isDarkModeNotifier.value);
  }

  static Future<void> loadTheme() async {
    final isDark = StorageService.getBool('isDark');
    isDarkModeNotifier.value = isDark;
  }
}

final document_service = DocumentServive();
