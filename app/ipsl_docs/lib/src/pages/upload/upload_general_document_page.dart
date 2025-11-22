import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/upload/upload_specifique_document_page.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:path/path.dart';

import '../../core/constant.dart';
import '../../core/utils.dart';
import '../../models/document.dart';
import '../../services/document.dart';
import '../../view_models/document.dart';
import '../../view_models/user.dart';
import '../../widget_tree.dart';
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
  final _formKeySubmit = GlobalKey<FormState>();
  double progress = 0;
  bool isSending = false;
  final documentViewModel = GetIt.I<DocumentViewModel>();
  final userViewModel = GetIt.I<UserViewModel>();
  final documentServive = GetIt.I<DocumentService>();

  Future<void> _submit(BuildContext context) async {
    if (!_formKeySubmit.currentState!.validate() || pickedFile == null) return;
    FocusScope.of(context).unfocus();

    setState(() => isSending = true);
    if (!await isConnectedToInternet()) {
      setState(() => isSending = false);
      if (!context.mounted) return;
      showNoConnectionMessage(context);
      return;
    }

    final path = join("Général", filenameController.text);
    final responseUpload = await documentServive.uploadDocument(
      file: File(pickedFile!.path!),
      path: path,
      userId: userViewModel.userNotifier.value!.id,
      onProgress: (received, total) {
        documentViewModel.updateProgress(received, total);
      },
    );
    final doc = Document(
      id: responseUpload!['id'],
      idUploader: userViewModel.userNotifier.value!.id,
      path: path,
      updatedAt: DateTime.parse(responseUpload['updated_at'] as String),
    );
    await documentViewModel.addDocument(doc);

    final int numberContribution = responseUpload['number_contribution'];
    await userViewModel.updateNumberContribution(numberContribution);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WidgetTree()),
      (route) => false,
    );

    if (!context.mounted) return;
    confirmSending(context);
    await documentViewModel.loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        spacing: 30,
        children: [
          Form(
            key: _formKeySubmit,
            child: TextFormField(
              controller: filenameController,
              decoration: const InputDecoration(labelText: 'Nom du fichier'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Champ requis' : null,
            ),
          ),

          pickedFile != null
              ? previewWidget(localPath: pickedFile!.path!, context: context)
              : PickFileButtun(onpress: pickFile),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: isSending ? null : () => _submit(context),
            child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
          ),

          ValueListenableBuilder<double>(
            valueListenable: documentViewModel.progress,
            builder: (context, progress, child) {
              if (isSending) {
                return customLinearProgressSending(progress);
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }
}
