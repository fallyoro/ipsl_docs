import 'package:flutter/material.dart';

import '../../../core/constant.dart';

Widget buildSendButton(
  BuildContext context,
  Future<void> Function() onPressed,
) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
    onPressed: () async {
      await onPressed();
    },
    child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
  );
}
