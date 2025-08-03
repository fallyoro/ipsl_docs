import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: AppColors.lightSystemBackground,
        // toolbarHeight: 60,
      ),

      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,

        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          minimumSize: const Size(200, 40),
          iconColor: Colors.white,
          // textStyle: TextStyle(color: Colors.white),
        ),
      ),

      scaffoldBackgroundColor: AppColors.lightSystemBackground,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(color: AppColors.darkSecondarySystemBackground),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          minimumSize: const Size(200, 40),
          iconColor: Colors.white,
          // textStyle: TextStyle(color: Colors.white),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkSecondarySystemBackground,
    );
  }
}
