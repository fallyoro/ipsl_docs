import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/upload/widget/custom_toast.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/widget_tree.dart';
import 'package:toastification/toastification.dart';

abstract class BaseUploadPage<T extends StatefulWidget> extends State<T> {
  final filenameController = TextEditingController();
  final formKeySubmit = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    filenameController.dispose();
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
