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

      scaffoldBackgroundColor: AppColors.lightSystemBackground,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(color: AppColors.darkSystemBackground),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppColors.darkSystemBackground,
    );
  }
}
