import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/views/home/widget/year_formater.dart';
import 'package:ipsl_docs/views/widgets/linear_progress.dart';
import 'package:path/path.dart';

class UploadFormContent extends StatefulWidget {
  //  final VoidCallback onSuccess;

  const UploadFormContent({super.key});

  @override
  State<UploadFormContent> createState() => _UploadFormContentState();
}

class _UploadFormContentState extends State<UploadFormContent> {
  final _formKeySubmit = GlobalKey<FormState>();
  final filenameController = TextEditingController();
  final yearController = TextEditingController();
  final subjectController = TextEditingController();
  final yearMaskFormatter = YearInputFormatter(); // ton formatter custom
  final viewModel = GetIt.I<DocumentViewModel>();
  final userViewModel = GetIt.I<UserViewModel>();
  final service = DocumentServive();

  String selectedClasse = 'Cpi1';
  String selectedCategory = 'cour';
  double progress = 0;
  bool isSending = false;
  PlatformFile? pickedFile;

  final classes = [
    'Cpi1',
    'Cpi2',
    'GeIT1',
    'GeIT2',
    'GeIT3',
    'GeM1',
    'GeM2',
    'GeM3',
    'GeC1',
    'GeC2',
    'GeC3',
  ];
  final categories = [
    'cour',
    'travaux pratique',
    'devoir',
    'travaux dirige',
    'tutorat',
    'utile',
    'rattrapage',
  ];

  @override
  void dispose() {
    filenameController.dispose();
    yearController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;

      setState(() {
        pickedFile = file;
        filenameController.text = file.name;
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

    final path = join(
      selectedClasse,
      subjectController.text,
      yearController.text,
      selectedCategory,
      filenameController.text,
    );
    final responseUpload = await service.uploadDocument(
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
    return Form(
      key: _formKeySubmit,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FontAwesomeIcons.cloudArrowUp,
              size: 48,
              color: AppColors.primaryColor,
            ),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final input = textEditingValue.text;
                if (input.isEmpty) return const <String>[];
                /*  List<String> subjects =
                    viewModel.documents.value
                        .map((e) => e.path.split("/").elementAt(2))
                        .toSet()
                        .toList();*/
                List<String> subjects = ['hello', 'yoro'];

                return subjects.where(
                  (s) => s.toLowerCase().contains(input.toLowerCase()),
                );
              },
              fieldViewBuilder: (
                context,
                controller,
                focusNode,
                onFieldSubmitted,
              ) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Matière'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Champ requis'
                              : null,
                  onChanged: (val) => subjectController.text = val,
                );
              },
              onSelected: (selection) => subjectController.text = selection,
            ),

            TextFormField(
              controller: filenameController,
              decoration: const InputDecoration(labelText: 'Nom du fichier'),
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
            ),

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

            Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 262),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Text("Classe"),
                        const Spacer(),
                        DropdownMenu<String>(
                          textAlign: TextAlign.end,
                          inputDecorationTheme: InputDecorationTheme(
                            border: InputBorder.none,
                          ),

                          initialSelection: selectedClasse,
                          onSelected: (String? value) {
                            setState(() {
                              selectedClasse = value!;
                            });
                          },
                          dropdownMenuEntries:
                              classes
                                  .map(
                                    (c) => DropdownMenuEntry<String>(
                                      value: c,
                                      label: c,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        const Text("Catégorie"),
                        const Spacer(),
                        DropdownMenu<String>(
                          width: 160,
                          textAlign: TextAlign.end,
                          inputDecorationTheme: InputDecorationTheme(
                            border: InputBorder.none,
                          ),
                          initialSelection: selectedCategory,
                          onSelected: (String? value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                          dropdownMenuEntries:
                              categories
                                  .map(
                                    (c) => DropdownMenuEntry<String>(
                                      value: c,
                                      label: c,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () => _submit(context),
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
