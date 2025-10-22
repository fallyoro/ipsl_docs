import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:path/path.dart';

import '../core/constant.dart';
import '../core/utils.dart';
import '../models/document.dart';
import '../services/document.dart';
import '../view_models/document.dart';
import '../view_models/user.dart';
import 'home/widget/year_formater.dart';

class UploadConcoursDocumentPage extends StatefulWidget {
  const UploadConcoursDocumentPage({super.key});

  @override
  State<UploadConcoursDocumentPage> createState() =>
      _UploadConcoursDocumentPageState();
}

class _UploadConcoursDocumentPageState
    extends State<UploadConcoursDocumentPage> {
  final _formKeySubmit = GlobalKey<FormState>();
  double progress = 0;
  bool isSending = false;
  final viewModel = GetIt.I<DocumentViewModel>();
  final yearMaskFormatter = YearInputFormatter(); // ton formatter custom
  final userViewModel = GetIt.I<UserViewModel>();
  final yearController = TextEditingController();
  final documentServive = GetIt.I<DocumentService>();
  final filenameController = TextEditingController();
  final List<String> materials = [
    "Mathématiques",
    "Physique",
    "Anglais",
    "Français",
  ];
  PlatformFile? pickedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      setState(() {
        pickedFile = file;
        if (filenameController.text == '') {
          filenameController.text = file.name;
        }
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKeySubmit.currentState!.validate() || pickedFile == null) return;
    FocusScope.of(context).unfocus();

    setState(() => isSending = true);
    if (!await isConnectedToInternet()) {
      setState(() => isSending = false);
      if (!context.mounted) return;
      showNoConnectionMessage(context);
      return;
    }

    final path = join("Concours", yearController.text, filenameController.text);
    final responseUpload = await documentServive.uploadDocument(
      file: File(pickedFile!.path!),
      path: path,
      userId: userViewModel.userNotifier.value!.id,
      onProgress: (received, total) {
        setState(() => progress = total > 0 ? received / total : 0);
      },
    );

    final doc = Document(
      id: responseUpload!['id'],
      idUploader: userViewModel.userNotifier.value!.id,
      path: path,
      updatedAt: responseUpload['updated_at'],
    );
    await viewModel.addDocument(doc);

    final int numberContribution = responseUpload['number_contribution'];
    await userViewModel.updateNumberContribution(numberContribution);

    setState(() => isSending = false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fichier envoyé')));
    await viewModel.loadDocuments();
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Partage de document")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 30,
          children: [
            Form(
              key: _formKeySubmit,
              child: Column(
                spacing: 30,
                children: [
                  TextFormField(
                    controller: yearController,
                    inputFormatters: [yearMaskFormatter],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Année universitaire',
                      hintText: "Exemple 2024-2025",
                      suffixIcon: IconButton(
                        onPressed: () {
                          yearController.clear();
                        },
                        icon: const Icon(FontAwesomeIcons.circleXmark),
                      ),
                    ),
                    validator: (value) {
                      final parts = value?.split('-') ?? [];
                      if (value == null || value.isEmpty) return 'Champ requis';
                      if (!RegExp(r'^\d{4}-\d{4}$').hasMatch(value)) {
                        return 'Format invalide';
                      }
                      if (int.parse(parts[1]) != int.parse(parts[0]) + 1) {
                        return 'Années incohérentes';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: filenameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du fichier',
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Champ requis'
                                : null,
                  ),
                ],
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: _pickFile,
              child: const Text(
                'Choisir un fichier',
                style: TextStyle(color: Colors.white),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: isSending ? null : () => _submit(context),
              child: const Text(
                'Envoyer',
                style: TextStyle(color: Colors.white),
              ),
            ),

            if (isSending) customLinearProgressSending(progress),
          ],
        ),
      ),
    );
  }
}
