import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/pages/upload/base_upload.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:path/path.dart';
import '../../core/constant.dart';
import '../../services/document.dart';
import '../../view_models/document.dart';
import '../../view_models/user.dart';
import '../home/widget/preview_widget.dart';
import '../home/widget/send_button.dart';
import '../home/widget/year_formater.dart';

class UploadConcoursDocumentPage extends StatefulWidget {
  const UploadConcoursDocumentPage({super.key});

  @override
  State<UploadConcoursDocumentPage> createState() =>
      _UploadConcoursDocumentPageState();
}

class _UploadConcoursDocumentPageState
    extends BaseUploadPage<UploadConcoursDocumentPage> {
  // final _formKeySubmit = GlobalKey<FormState>();
  final yearMaskFormatter = YearInputFormatter();
  final userViewModel = GetIt.I<UserViewModel>();
  final yearController = TextEditingController();
  final documentServive = GetIt.I<DocumentService>();
  final List<String> materials = [
    "Mathématiques",
    "Physique",
    "Anglais",
    "Français",
  ];
  Future<void> pickFile() async {
    await documentViewModel.pickFile();
    filenameController.text = documentViewModel.pickedFileNotifier.value!.name;
    setState(() {});
  }

  @override
  void dispose() {
    yearController.dispose();
    documentViewModel.pickedFileNotifier.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 30,
          children: [
            Form(
              key: formKeySubmit,
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
            ValueListenableBuilder<PlatformFile?>(
              valueListenable: documentViewModel.pickedFileNotifier,
              builder: (context, file, _) {
                return file != null
                    ? previewWidget(localPath: file.path, context: context)
                    : PickFileButtun(onpress: pickFile);
              },
            ),

            ValueListenableBuilder<double>(
              valueListenable: documentViewModel.progress,
              builder: (context, progress, child) {
                if (documentViewModel.isSending.value) {
                  return customLinearProgressSending(progress);
                } else {
                  return buildSendButton(context, () {
                    final path = join(
                      "Concours",
                      yearController.text,
                      filenameController.text,
                    );
                    onSubmit(context, path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PickFileButtun extends StatelessWidget {
  final VoidCallback onpress;
  const PickFileButtun({super.key, required this.onpress});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.attach_file),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
      onPressed: onpress,
      label: const Text(
        "Choisir un fichier",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
