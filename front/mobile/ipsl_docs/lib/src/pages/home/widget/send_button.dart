import 'package:flutter/material.dart';

import '../../../core/constant.dart';

Widget buildSendButton(BuildContext context, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
    onPressed: onPressed,
    child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
  );
}
