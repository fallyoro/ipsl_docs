import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      cardColor: AppColors.lightSecondarySystemBackground,
      appBarTheme: AppBarTheme(color: AppColors.lightSystemBackground),
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,

        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: AppColors.lightSystemBackground,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      cardColor: AppColors.darkSecondarySystemBackground,
      appBarTheme: AppBarTheme(color: AppColors.darkSystemBackground),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkSystemBackground,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    );
  }
}
