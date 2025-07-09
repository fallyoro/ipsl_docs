

 import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget folderHomeIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        FaIcon(Icons.folder, size: 48, color: Colors.amber),
        FaIcon(FontAwesomeIcons.house, size: 18, color: Colors.white),
      ],
    );
  }