import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/upload/widget/custom_toast.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:toastification/toastification.dart';

abstract class BaseUploadPage<T extends StatefulWidget> extends State<T> {
  final filenameController = TextEditingController();
  final formKeySubmit = GlobalKey<FormState>();
  DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();

  @override
  void dispose() {
    filenameController.dispose();
    super.dispose();
  }

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

  Future<void> onSubmit(BuildContext context, String path) async {
    final documentViewModel = GetIt.I<DocumentViewModel>();
    if (!formKeySubmit.currentState!.validate() ||
        documentViewModel.pickedFileNotifier.value == null) {
      return;
    }
    FocusScope.of(context).unfocus();

    // final path = join("Général", filenameController.text);
    try {
      await documentViewModel.submitDocument(context: context, path: path);
    } catch (e) {
      return;
    }
    await documentViewModel.loadDocuments();
    filenameController.clear();
    // confirmSending();
    setState(() {});
    // if (!context.mounted) return;
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => WidgetTree()),
    //   (route) => false,
    // );
  }

  // 'Document envoyé avec succès',
  // text: 'Merci pour votre contribution !',
}

void confirmSending() {
  customToast(
    title: 'Document envoyé avec succès',
    description: 'Merci pour votre contribution',
    primaryColor: Colors.green,
    icon: Icon(Icons.check),
    type: ToastificationType.success,
  );
}
