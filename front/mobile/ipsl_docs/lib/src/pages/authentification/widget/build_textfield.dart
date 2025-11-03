import 'package:flutter/material.dart';

import '../../../core/constant.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String? Function(String?) validator,
  bool obscure = false,
  Widget? suffix,
  required bool isDark,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor:
          isDark
              ? AppColors.darkSystemBackground
              : AppColors.lightSecondarySystemBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    ),
  );
}
