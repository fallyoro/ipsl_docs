import 'package:flutter/material.dart';

class AppColors {
  // Returns the same primary color regardless of brightness (light/dark mode)
  static const Color primaryColor = Color.fromARGB(255, 184, 92, 52);

  // Backgrounds Dark
  static const Color darkSystemBackground = Color.fromARGB(255, 28, 28, 30);
  static const Color darkSecondarySystemBackground = Color.fromARGB(
    255,
    44,
    44,
    46,
  );
  static const Color darkTertiarySystemBackground = Color.fromARGB(
    255,
    58,
    58,
    60,
  );

  // Backgrounds Light
  static const Color lightSystemBackground = Color.fromARGB(255, 242, 242, 247);
  static const Color lightSecondarySystemBackground = Colors.white;
  static const Color lightTertiarySystemBackground = Color.fromARGB(
    255,
    229,
    229,
    234,
  ); // Gris clair

  // Labels (text)
  static const Color darkLabel = Color.fromARGB(255, 255, 255, 255);
  static const Color darkSecondaryLabel = Color.fromARGB(153, 235, 235, 245);
  static const Color darkTertiaryLabel = Color.fromARGB(128, 235, 235, 245);
  static const Color darkQuaternaryLabel = Color.fromARGB(76, 235, 235, 245);

  // Labels (text) - Light
  static const Color lightLabel = Color.fromARGB(
    255,
    0,
    0,
    0,
  ); // Texte principal (noir)
  static const Color lightSecondaryLabel = Color.fromARGB(
    153,
    60,
    60,
    67,
  ); // 60% d’opacité
  static const Color lightTertiaryLabel = Color.fromARGB(
    128,
    60,
    60,
    67,
  ); // 50% d’opacité

  // Separators
  static const Color darkSeparator = Color.fromARGB(60, 84, 84, 88);
  static const Color darkOpaqueSeparator = Color.fromARGB(255, 56, 56, 58);

  // Fills
  static const Color darkSystemFill = Color.fromRGBO(120, 120, 128, 0.36);

  // Grays
  static const Color darkSystemGray = Color.fromARGB(255, 142, 142, 147);
  static const Color darkSystemGray6 = Color.fromARGB(255, 28, 28, 30);
}

final String host = "192.168.1.153";
// final String host = "10.151.102.82";
final int port = 8000;
