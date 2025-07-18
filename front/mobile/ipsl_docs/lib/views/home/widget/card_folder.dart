


import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';

class CardFolder extends StatefulWidget {
  const CardFolder({
    super.key,
    required this.screenWidth,
    required this.folder,
    required this.isDark,
  });

  final double screenWidth;
  final String folder;
  final bool isDark;

  @override
  State<CardFolder> createState() => _CardFolderState();
}

class _CardFolderState extends State<CardFolder> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    if (widget.isDark) {
      backgroundColor =
          isHover
              ? AppColors.darkTertiarySystemBackground
              : AppColors.darkSecondarySystemBackground;
    } else {
      backgroundColor =
          isHover
              ? AppColors.lightTertiarySystemBackground
              : AppColors.lightSecondarySystemBackground;
    }
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: Card(
        elevation: widget.isDark ? 0 : 2,

        color: backgroundColor,

        // elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder,
              size: widget.screenWidth < 600 ? 60 : 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              widget.folder,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.screenWidth < 600 ? 14 : 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}