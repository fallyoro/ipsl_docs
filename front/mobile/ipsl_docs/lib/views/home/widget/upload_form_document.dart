import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home/widget/year_formater.dart';
import 'package:ipsl_docs/widget_tree.dart';

class UploadFormContent extends StatefulWidget {
  final VoidCallback onSuccess;

  const UploadFormContent({super.key, required this.onSuccess});

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
  final categories = ['cour', 'tp', 'devoir', 'td', 'tutorat', 'utile'];
  final documents = SQLiteService.instance.getDocuments();

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

    final user = SQLiteService.instance.getUser();
    final idDocument = await service.uploadDocument(
      file: File(pickedFile!.path!),
      filename: filenameController.text,
      classe: selectedClasse,
      subject: subjectController.text,
      year: yearController.text,
      categorie: selectedCategory,
      userId: user!['id'],
      onProgress: (received, total) {
        setState(() => progress = total > 0 ? received / total : 0);
      },
    );

    final doc = Document(
      id: idDocument!,
      idUploader: user['id'],
      filename: filenameController.text,
      year: yearController.text,
      classe: selectedClasse,
      subject: subjectController.text,
      categorie: selectedCategory,
    );
    viewModel.addDocument(doc);

    setState(() => isSending = false);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fichier envoyé')));

    widget.onSuccess(); // ← déclenche la fermeture si besoin
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKeySubmit,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
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
                return documents
                    .map((d) => d['subject'] as String)
                    .where(
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
              decoration: const InputDecoration(
                labelText: 'Année scolaire',
                hintText: "Exemple 2024/2025",
              ),
              validator: (value) {
                final parts = value?.split('/') ?? [];
                if (value == null || value.isEmpty) return 'Champ requis';
                if (!RegExp(r'^\d{4}/\d{4}$').hasMatch(value)) {
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
                constraints: BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        const Text("Classe"),
                        const Spacer(),
                        DropdownButton<String>(
                          value: selectedClasse,
                          items:
                              classes
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setState(() => selectedClasse = v!),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        const Text("Catégorie"),
                        const Spacer(),
                        DropdownButton<String>(
                          value: selectedCategory,
                          items:
                              categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() => selectedCategory = v!),
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
                minimumSize: const Size(200, 40),
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
                minimumSize: const Size(200, 40),
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
