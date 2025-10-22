import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/src/models/document.dart';
import 'package:flutter/material.dart';

class DocumentProgressWidget extends StatelessWidget {
  final Document doc;
  final Future<void> Function(Document) onCancel; // callback pour annuler

  const DocumentProgressWidget({
    super.key,
    required this.doc,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: ValueListenableBuilder<double>(
            valueListenable: doc.progress,
            builder: (context, progress, child) {
              return CircularProgressIndicator(
                value: progress, // entre 0.0 et 1.0
                strokeWidth: 4,
                color: Colors.green,
              );
            },
          ),
        ),
        IconButton(
          onPressed: () async {
            await onCancel(doc);
          },
          icon: const Icon(FontAwesomeIcons.xmark),
        ),
      ],
    );
  }
}
