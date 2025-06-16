import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._(); // Constructeur privé

  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
  static void toggleTheme() {
    isDarkModeNotifier.value = !isDarkModeNotifier.value;
  }
}