import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/home/widget/preview_widget.dart';
import 'package:ipsl_docs/src/pages/home/widget/send_button.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/upload/widget/custom_toast.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:toastification/toastification.dart';

void confirmSending() {
  customToast(
    title: 'Document envoyé avec succès',
    description: 'Merci pour votre contribution',
    icon: Icon(Icons.check),
    type: ToastificationType.success,
  );
}

abstract class BaseUploadPage<T extends StatefulWidget> extends State<T> {
  final filenameController = TextEditingController();
  final formKeySubmit = GlobalKey<FormState>();
  DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();

  void cancenPickFile() {
    documentViewModel.pickedFileNotifier.value = null;
    filenameController.clear();
  }

  @override
  void dispose() {
    filenameController.dispose();
    super.dispose();
  }

  ValueListenableBuilder<PlatformFile?> filePreviewSection() {
    return ValueListenableBuilder<PlatformFile?>(
      valueListenable: documentViewModel.pickedFileNotifier,
      builder: (context, file, _) {
        return file != null
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  IgnorePointer(
                    ignoring:
                        false, // ← laisse passer les clics sur le bouton, pas sur le preview
                    child: previewWidget(
                      localPath: file.path,
                      context: context,
                    ),
                  ),

                  Positioned(
                    top: -10,
                    right: -10,
                    child: InkWell(
                      onTap: () {
                        cancenPickFile();
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : PickFileButtun(onpress: pickFile);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // documentViewModel = GetIt.I<DocumentViewModel>();
    documentViewModel.errorNotifier.addListener(() {
      final message = documentViewModel.errorNotifier.value;
      if (message != null) {
        customToast(
          title: "Erreur",
          description: message,
          icon: Icon(Icons.error),
          type: ToastificationType.error,
        );
        documentViewModel.errorNotifier.value = null;
      }
    });
    documentViewModel.success.addListener(() {
      if (documentViewModel.success.value == true) {
        confirmSending();
        // if (!mounted) return;
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (_) => WidgetTree()),
        //   (route) => false,
        // );
        documentViewModel.success.value = null;
      }
    });
  }

  Future<void> onSubmit(BuildContext context, String path) async {
    if (!formKeySubmit.currentState!.validate() ||
        documentViewModel.pickedFileNotifier.value == null) {
      return;
    }
    FocusScope.of(context).unfocus();

    try {
      final String? error = await documentViewModel.submitDocument(
        context: context,
        path: path,
        fileName: filenameController.text,
      );
      if (error != null) {
        // documentViewModel.pickedFileNotifier.value = null;
        documentViewModel.isSending.value = false;
        return;
      }
    } catch (e) {
      return;
    }
    // await documentViewModel.loadDocuments();
    filenameController.clear();
    // confirmSending();
    setState(() {});
  }

  Future<void> pickFile() async {
    await documentViewModel.pickFile();
    final rawName = documentViewModel.pickedFileNotifier.value!.name;
    final cleanedName = rawName.replaceAll(' ', '');
    filenameController.text = cleanedName;
    setState(() {});
  }

  ValueListenableBuilder<double> sendButtonSection(
    Future<void> Function() onPressed,
    // String path,
  ) {
    return ValueListenableBuilder<double>(
      valueListenable: documentViewModel.progress,
      builder: (context, progress, child) {
        if (documentViewModel.isSending.value) {
          // return customLinearProgressSending(progress);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              customLinearProgressSending(documentViewModel.progress.value),
              const SizedBox(height: 8),
              // cancelUploadButton(),
            ],
          );
        } else {
          return buildSendButton(context, () => onPressed());
        }
      },
    );
  }

  Widget cancelUploadButton() {
    return ElevatedButton(
      onPressed: () {
        documentViewModel.cancelUpload();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        fixedSize: const Size(150, 40),
      ),
      child: const Text("Annuler", style: TextStyle(color: Colors.white)),
    );
  }
}
