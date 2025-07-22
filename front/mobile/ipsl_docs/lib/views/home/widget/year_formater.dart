import 'package:flutter/services.dart';

class YearInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Enlever tous les '/' pour repartir sur du "propre"
    String digitsOnly = newValue.text.replaceAll('/', '');

    // Limiter à 8 chiffres max (4 + 4)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    String formatted;

    // Dès qu'on a au moins 4 chiffres, on insère le '/'
    if (digitsOnly.length >= 4) {
      // On prend les 4 premiers chiffres
      String firstPart = digitsOnly.substring(0, 4);
      // Puis le reste (même si vide)
      String secondPart = digitsOnly.length > 4 ? digitsOnly.substring(4) : '';
      formatted = '$firstPart/$secondPart';
    } else {
      // Moins de 4 chiffres : pas de '/'
      formatted = digitsOnly;
    }

    // Position du curseur (fin du texte)
    int cursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
