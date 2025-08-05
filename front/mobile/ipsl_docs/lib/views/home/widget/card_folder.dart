import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              ? AppColors.darkSystemBackground
              : AppColors.darkSecondarySystemBackground;
    } else {
      backgroundColor =
          isHover
              ? AppColors.lightSecondarySystemBackground
              : AppColors.lightSystemBackground;
    }
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: Card(
        elevation: 0,

        color: backgroundColor,

        child: Column(
          spacing: 3,
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.solidFolder, size: 75, color: Colors.amber),

            SizedBox(
              height: 46,
              child: Text(
                widget.folder,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
