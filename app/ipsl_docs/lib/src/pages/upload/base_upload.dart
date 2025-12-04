import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
        documentViewModel.pickedFile == null) {
      return;
    }
    FocusScope.of(context).unfocus();

    // final path = join("Général", filenameController.text);
    await documentViewModel.submitDocument(context: context, path: path);
    setState(() {});
    // if (!context.mounted) return;
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => WidgetTree()),
    //   (route) => false,
    // );

    if (!context.mounted) return;
    confirmSending(context);
  }

  void confirmSending(BuildContext context) {
    toastification.show(
      context: context, // optional if you use ToastificationWrapper
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 5),
      title: Text(
        'Document envoyé avec succès',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      description: RichText(
        text: TextSpan(
          text: 'Merci pour votre contribution !',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      alignment: Alignment.bottomCenter,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: const Icon(Icons.check),
      showIcon: true,
      primaryColor: Colors.green,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 16,
          offset: Offset(0, 16),
          spreadRadius: 0,
        ),
      ],
      showProgressBar: true,
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.onHover,
        buttonBuilder: (context, onClose) {
          return OutlinedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Close'),
          );
        },
      ),
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: true,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
        onCloseButtonTap:
            (toastItem) => print('Toast ${toastItem.id} close button tapped'),
        onAutoCompleteCompleted:
            (toastItem) =>
                print('Toast ${toastItem.id} auto complete completed'),
        onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
      ),
    );
  }
}
