import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../core/constant.dart';

class ActionButton extends StatelessWidget {
  final bool isLoading;
  final String action;
  final double actionFontSize;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const ActionButton({
    super.key,
    required this.isLoading,
    required this.action,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.actionFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ElevatedButton.styleFrom(
        // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        fixedSize: Size(width, height),
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.primaryColor,
      ),
      onPressed: isLoading ? null : onPressed,
      child:
      isLoading
          ? const SpinKitThreeBounce(color: Colors.white, size: 25)
          : Text(
        action,
        style: TextStyle(color: Colors.white, fontSize: actionFontSize),
      ),
    );
  }
}
