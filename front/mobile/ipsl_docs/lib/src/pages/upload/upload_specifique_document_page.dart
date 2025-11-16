import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/matiere.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/models/document.dart';
import 'package:ipsl_docs/src/pages/home/widget/preview_widget.dart';
import 'package:ipsl_docs/src/pages/home/widget/year_formater.dart';
import 'package:ipsl_docs/src/pages/upload/base_upload.dart';
import 'package:ipsl_docs/src/pages/upload/upload_concour_document_page.dart';
import 'package:ipsl_docs/src/pages/widgets/linear_progress.dart';
import 'package:ipsl_docs/src/services/document.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:path/path.dart';

import '../../widget_tree.dart';
import '../home/widget/send_button.dart';

void confirmSending(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Fichier envoyé, merci de votre contribution'),
    ),
  );
}

class UploadSpecifiqueDocumentPage extends StatefulWidget {
  const UploadSpecifiqueDocumentPage({super.key});

  @override
  State<UploadSpecifiqueDocumentPage> createState() =>
      _UploadSpecifiqueDocumentPageState();
}

class _UploadSpecifiqueDocumentPageState
    extends BaseUploadPage<UploadSpecifiqueDocumentPage> {
  final _formKeySubmit = GlobalKey<FormState>();
  final yearController = TextEditingController();
  final subjectController = TextEditingController();
  final yearMaskFormatter = YearInputFormatter();
  DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();
  UserViewModel userViewModel = GetIt.I<UserViewModel>();
  DocumentService service = GetIt.I<DocumentService>();
  String selectedClasse = 'Cpi1';
  String selectedCategory = 'cour';
  bool isSending = false;

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
  Widget build(BuildContext context) {
    List<String> subjects = matiere[selectedClasse]!.toSet().toList();
    return SingleChildScrollView(
      child: Form(
        key: _formKeySubmit,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Documents specifique a une classe",
                style: Theme.of(context).textTheme.bodyMedium,
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
                                subjectController.text = '';
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
                    // style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  items:
                      subjects.map<DropdownMenuItem<String>>((String subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(
                            subject,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  value:
                      subjectController.text.isNotEmpty
                          ? subjectController.text
                          : null,
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
                  dropdownStyleData: const DropdownStyleData(maxHeight: 200),
                  menuItemStyleData: const MenuItemStyleData(height: 40),
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
                      return item.value!.toLowerCase().contains(
                        searchValue.toLowerCase(),
                      );
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
                decoration: const InputDecoration(
                  labelText: 'Nom du fichier',
                  labelStyle: TextStyle(fontSize: 16),
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
                  labelStyle: TextStyle(fontSize: 16),
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

              pickedFile != null
                  ? previewWidget(
                    localPath: pickedFile!.path!,
                    context: context,
                  )
                  : PickFileButtun(onpress: pickFile),

              const SizedBox(height: 16),
              buildSendButton(context, () => _submit(context)),

              ValueListenableBuilder<double>(
                valueListenable: documentViewModel.progress,
                builder: (context, progress, child) {
                  if (isSending) {
                    return customLinearProgressSending(progress);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    yearController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKeySubmit.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    if (pickedFile == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir un fichier')),
      );
      return;
    }
    if (subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veillez selectioner une matiere')),
      );
      return;
    }

    isSending = true;
    if (!await isConnectedToInternet()) {
      isSending = false;
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
        documentViewModel.updateProgress(received, total);
      },
    );

    DateTime updatedAt = DateTime.parse(
      responseUpload?['updated_at'] as String,
    );
    final doc = Document(
      id: responseUpload!['id'],
      idUploader: userViewModel.userNotifier.value!.id,
      path: path,
      updatedAt: updatedAt,
    );
    await documentViewModel.addDocument(doc);

    final int numberContribution = responseUpload['number_contribution'];
    await userViewModel.updateNumberContribution(numberContribution);
    if (!context.mounted) return;

    if (!context.mounted) return;
    confirmSending(context);
    await documentViewModel.loadDocuments();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => WidgetTree()),
      (route) => false,
    );
    documentViewModel.reset();
  }
}
