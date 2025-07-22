import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';

SliverAppBar CustomSliverAppBar(bool isDark2) {
  return SliverAppBar(
    floating: true,
    snap: true,
    iconTheme: IconThemeData(color: Colors.white),
    backgroundColor:
        isDark2 ? AppColors.darkSystemBackground : AppColors.primaryColor,
    title: Text(
      "Hello",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: Colors.white,
      ),
    ),

    actions: [
      IconButton(
        onPressed: () => ThemeController.toggleTheme(),

        icon:
            isDark2
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
      ),
    ],
  );
}
