import "dart:io";

import "package:flutter/material.dart";

Future<void> showDeleteDialog({
  required BuildContext context,
  required File file,
  required VoidCallback onDeleted,
}) async {
  return showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("Supprimer ce fichier"),
        actions: [
          TextButton(
            child: Text("Oui"),
            onPressed: () async {
              await file.delete();
              onDeleted();
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
