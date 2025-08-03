import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/views/home/widget/upload_form_document.dart';

Future<dynamic> builBottomSheetUpload(BuildContext context) {
  bool isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,

    builder:
        (context) => Padding(
          padding: EdgeInsets.only(
            //info Permet que le bottomsheet ne soit pas cache par le clavier
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? AppColors.darkSystemBackground
                        : AppColors.lightSystemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,

                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  UploadFormContent(onSuccess: () => Navigator.pop(context)),
                ],
              ),
            ),
          ),
        ),
  );
}
