import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class BaseUploadPage<T extends StatefulWidget> extends State<T> {
  final filenameController = TextEditingController();
  PlatformFile? pickedFile;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      setState(() {
        pickedFile = file;
        filenameController.text = file.name;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    filenameController.dispose();
  }
}
