import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

import '../../services/document.dart';
import '../../view_models/user.dart';
import 'base_upload.dart';

class UploadGeneralDocumentPage extends StatefulWidget {
  const UploadGeneralDocumentPage({super.key});

  @override
  State<UploadGeneralDocumentPage> createState() =>
      _UploadGeneralDocumentPageState();
}

class _UploadGeneralDocumentPageState
    extends BaseUploadPage<UploadGeneralDocumentPage> {
  // final _formKeySubmit = GlobalKey<FormState>();
  final userViewModel = GetIt.I<UserViewModel>();
  final documentServive = GetIt.I<DocumentService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        spacing: 30,
        children: [
          Form(
            key: formKeySubmit,
            child: TextFormField(
              controller: filenameController,
              decoration: const InputDecoration(labelText: 'Nom du fichier'),
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
            ),
          ),

          filePreviewSection(),

          sendButtonSection(join("Général", filenameController.text)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    documentViewModel.pickedFileNotifier.value = null;
    super.dispose();
  }
}
