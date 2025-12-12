import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/home/widget/send_button.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:path/path.dart';

import '../../services/document.dart';
import '../../view_models/user.dart';
import '../home/widget/preview_widget.dart';
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
