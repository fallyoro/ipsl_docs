import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:path/path.dart';

import '../../core/constant.dart';
import '../../services/document.dart';
import '../../view_models/document.dart';
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
  final documentViewModel = GetIt.I<DocumentViewModel>();
  final userViewModel = GetIt.I<UserViewModel>();
  final documentServive = GetIt.I<DocumentService>();

  Future<void> pickFile() async {
    await documentViewModel.pickFile();
    filenameController.text = documentViewModel.pickedFile!.name;
    setState(() {});
  }

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
              validator: (value) =>
                  value == null || value.isEmpty ? 'Champ requis' : null,
            ),
          ),

          documentViewModel.pickedFile != null
              ? previewWidget(
                  localPath: documentViewModel.pickedFile!.path!,
                  context: context,
                )
              : PickFileButtun(onpress: pickFile),

          ValueListenableBuilder<bool>(
            valueListenable: documentViewModel.isSending,
            builder: (context, isSending, _) {
              if (isSending) {
                return Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: () {
                  final path = join("Général", filenameController.text);
                  onSubmit(context, path);
                },
                child: const Text(
                  'Envoyer',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),

          ValueListenableBuilder<double>(
            valueListenable: documentViewModel.progress,
            builder: (context, progress, child) {
              if (documentViewModel.isSending.value) {
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
