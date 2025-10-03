import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/constant.dart';

class CardFolder extends StatefulWidget {
  const CardFolder({super.key, required this.folder});

  final String folder;

  @override
  State<CardFolder> createState() => _CardFolderState();
}

class _CardFolderState extends State<CardFolder> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
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

      child: Column(
        spacing: 3,
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.solidFolder, size: 70, color: Colors.amber),

          SizedBox(
            height: 35,
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
    );
  }
}
