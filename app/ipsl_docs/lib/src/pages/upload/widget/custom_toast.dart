import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

// 'Document envoyé avec succès',
// text: 'Merci pour votre contribution !',
void customToast({
  required BuildContext context,
  required String title,
  required String description,
  required Color primaryColor,
  required Icon icon,
  required ToastificationType type,
}) {
  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: type,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    description: RichText(
      text: TextSpan(
        text: description,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    ),
    alignment: Alignment.bottomCenter,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 300),
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    icon: icon,
    showIcon: true,
    primaryColor: primaryColor,
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
  );
}
