import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/matiere.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/models/document.dart';
import 'package:ipsl_docs/src/services/document.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:ipsl_docs/src/pages/home/widget/year_formater.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
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
  final yearMaskFormatter = YearInputFormatter();
  DocumentViewModel viewModel = GetIt.I<DocumentViewModel>();
  UserViewModel userViewModel = GetIt.I<UserViewModel>();
  DocumentService service = GetIt.I<DocumentService>();
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
    if (pickedFile == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un fichier')),
      );
      return;
    }
    if (!_formKeySubmit.currentState!.validate()) return;
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
    logInfo("response upload ${responseUpload?.toString()}");
    DateTime updatedAt = DateTime.parse(
      responseUpload?['updated_at'] as String,
    );
    final doc = Document(
      id: responseUpload!['id'],
      idUploader: userViewModel.userNotifier.value!.id,
      path: path,
      updatedAt: updatedAt,
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
    List<String> subjects = matiere[selectedClasse] ?? [];
    return Form(
      key: _formKeySubmit,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FontAwesomeIcons.cloudArrowUp,
              size: 40,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 8),
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
                        Text(
                          "Classe",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
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
                        Text(
                          "Catégorie",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
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
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Matière',
                  ///style: Theme.of(context).textTheme.bodyLarge,
                ),
                items: subjects.map<DropdownMenuItem<String>>((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                value: subjectController.text.isNotEmpty ? subjectController.text : null,
                onChanged: (String? value) {
                  if (value == null) return;
                  setState(() {
                    subjectController.text = value;
                  });
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 200,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 40,
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: subjectController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Rechercher une matière…',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value!.toLowerCase().contains(searchValue.toLowerCase());
                  },
                ),
                onMenuStateChange: (bool isOpen) {
                  if (!isOpen) {
                    // clair l’input de recherche quand on ferme le menu
                    subjectController.clear();
                  }
                },
              ),
            ),

            TextFormField(
              controller: filenameController,
              decoration: const InputDecoration(labelText: 'Nom du fichier',
              labelStyle:  TextStyle(
                fontSize: 16,
              )
              ),
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
                labelStyle:  TextStyle(
                  fontSize: 16,
                ),
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

            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pickedFile != null ? Color.fromARGB(60, 184, 92, 52) : AppColors.primaryColor,
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