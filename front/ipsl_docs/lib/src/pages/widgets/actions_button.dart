import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/constant.dart';

class AuthButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const AuthButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width = 300,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        fixedSize: Size(width, height),
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.primaryColor,
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
