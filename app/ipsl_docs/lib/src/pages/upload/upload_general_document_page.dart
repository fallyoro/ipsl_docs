import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/home/widget/send_button.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/upload/widget/custom_toast.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:path/path.dart';
import 'package:toastification/toastification.dart';

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
  late DocumentViewModel documentViewModel;
  final userViewModel = GetIt.I<UserViewModel>();
  final documentServive = GetIt.I<DocumentService>();

  @override
  void initState() {
    super.initState();
    documentViewModel = GetIt.I<DocumentViewModel>();
    documentViewModel.errorNotifier.addListener(() {
      final message = documentViewModel.errorNotifier.value;
      if (message != null) {
        customToast(
          title: "Erreur",
          description: message,
          primaryColor: Colors.red,
          icon: Icon(Icons.error),
          type: ToastificationType.error,
        );
        documentViewModel.errorNotifier.value = null;
      }
    });
    documentViewModel.success.addListener(() {
      if (documentViewModel.success.value == true) {
        confirmSending();
        documentViewModel.success.value = null;
      }
    });
  }

  Future<void> pickFile() async {
    await documentViewModel.pickFile();
    filenameController.text = documentViewModel.pickedFileNotifier.value!.name;
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
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
            ),
          ),

          ValueListenableBuilder<PlatformFile?>(
            valueListenable: documentViewModel.pickedFileNotifier,
            builder: (context, file, _) {
              return file != null
                  ? previewWidget(localPath: file.path, context: context)
                  : PickFileButtun(onpress: pickFile);
            },
          ),

          ValueListenableBuilder<double>(
            valueListenable: documentViewModel.progress,
            builder: (context, progress, child) {
              if (documentViewModel.isSending.value) {
                return customLinearProgressSending(progress);
              } else {
                return buildSendButton(context, () async {
                  final path = join("Général", filenameController.text);
                  await onSubmit(context, path);
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
