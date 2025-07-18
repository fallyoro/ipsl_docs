import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home/home.dart';
import 'package:ipsl_docs/views/profile.dart';
import 'package:ipsl_docs/views/widgets/sidebar.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/Responsive.dart';

List<Widget> pages = [
  Home(),
  const Profile(),
  const Center(child: Text("Paramètres")),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final PageController _pageController = PageController();
  int _selectedPage = 0;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  void _openUploadDialog() {
    showDialog(
      context: context,
      builder: (_) => UploadDialog(context: context),
    );
  }

  void _openUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // pour des coins arrondis visibles
      builder:
          (_) => DraggableScrollableSheetUpload(controller: _sheetController),
    );
  }

  void _onItemSelected(int index) {
    setState(() => _selectedPage = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        final isMobile = Responsive.isMobile(context);
        final isDestop = Responsive.isDesktop(context);
        final isTablet = Responsive.isTablet(context);
        double screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            backgroundColor: AppColors.primaryColor,
            onPressed: _openUploadDialog,
            child: const Icon(FontAwesomeIcons.plus, color: Colors.white),
          ),
          appBar: buildAppbarWidgetTree(isDark),

          drawer:
              (isMobile)
                  ? Drawer(
                    backgroundColor:
                        isDark
                            ? AppColors.darkSystemBackground
                            : AppColors.lightSystemBackground,
                    child: ListView(
                      children: [
                        const DrawerHeader(
                          child: Text("Menu", style: TextStyle(fontSize: 24)),
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.house),
                          title: const Text("Accueil"),
                          selected: _selectedPage == 0,
                          onTap: () {
                            _onItemSelected(0);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.userLarge),
                          title: const Text("Profil"),
                          selected: _selectedPage == 1,
                          onTap: () {
                            _onItemSelected(1);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.gear),
                          title: const Text("Paramètres"),
                          selected: _selectedPage == 2,
                          onTap: () {
                            _onItemSelected(2);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                  : null,

          body:
              (isMobile)
                  ? PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged:
                        (index) => setState(() => _selectedPage = index),
                    children: pages,
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SideBar(
                        selectedIndex: _selectedPage,
                        onItemSelected: _onItemSelected,
                        width: isTablet ? 200.0 : 300.0,
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: pages[_selectedPage],
                        ),
                      ),
                    ],
                  ),

          bottomNavigationBar:
              ((Theme.of(context).platform == TargetPlatform.android ||
                      Theme.of(context).platform == TargetPlatform.iOS))
                  ? SalomonBottomBar(
                    backgroundColor:
                        isDark
                            ? AppColors.darkSecondarySystemBackground
                            : Colors.white,
                    currentIndex: _selectedPage,
                    onTap: _onItemSelected,
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.house, size: 30),
                        title: const Text('Accueil'),
                        selectedColor: isDark ? Colors.white : Colors.black,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.userLarge),
                        title: const Text('Profil'),
                        selectedColor: isDark ? Colors.white : Colors.black,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.gear),
                        title: const Text('Paramètres'),
                        selectedColor: isDark ? Colors.white : Colors.black,
                      ),
                    ],
                  )
                  : null,
        );
      },
    );
  }

  AppBar buildAppbarWidgetTree(bool isDark) {
    return AppBar(
      title: Text(
        'Ipsl Docs',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
      ),
      backgroundColor:
          isDark
              ? AppColors.darkSystemBackground
              : AppColors.lightSystemBackground,
      actions: [
        IconButton(
          onPressed: () => ThemeController.toggleTheme(),

          icon:
              isDark
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
        ),
      ],
    );
  }
}

Row customLinearProgressSending(double progress) {
  return Row(
    children: [
      // Barre de progression
      Expanded(
        child: LinearProgressIndicator(
          value: progress,
          borderRadius: BorderRadius.circular(50),
          minHeight: 6,
          color: Colors.green,
          backgroundColor: Colors.grey.shade300,
        ),
      ),
      const SizedBox(width: 10),

      // Pourcentage
      Text(
        '${(progress * 100).toStringAsFixed(0)}%',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class DraggableScrollableSheetUpload extends StatefulWidget {
  final DraggableScrollableController? controller;

  const DraggableScrollableSheetUpload({super.key, this.controller});

  @override
  State<DraggableScrollableSheetUpload> createState() =>
      _DraggableScrollableSheetUploadState();
}

class _DraggableScrollableSheetUploadState
    extends State<DraggableScrollableSheetUpload> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.hardEdge,
      child: DraggableScrollableSheet(
        controller: widget.controller,
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            children: List.generate(
              10,
              (i) => ListTile(title: Text('Item $i')),
            ),
          );
        },
      ),
    );
  }
}

class UploadDialog extends StatefulWidget {
  final BuildContext context;
  const UploadDialog({super.key, required this.context});

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  List<Map<String, dynamic>> documents = SQLiteService.instance.getDocuments();
  final filenameController = TextEditingController();
  final yearController = TextEditingController();
  final subjectController = TextEditingController();
  String selectedClasse = 'Cpi1';
  String selectedCategory = 'cour';
  double progress = 0;
  bool isSending = false;
  PlatformFile? pickedFile;
  final viewModel = GetIt.I<DocumentViewModel>();
  // final docs = GetIt.I

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
  final service = DocumentServive();

  @override
  void dispose() {
    filenameController.dispose();
    yearController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      pickedFile = result.files.single;
      filenameController.text = pickedFile!.name;
      setState(() {});
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (pickedFile == null ||
        filenameController.text.isEmpty ||
        yearController.text.isEmpty ||
        subjectController.text.isEmpty) {
      _showAlert('Champs manquants', context);
      return;
    }
    setState(() => isSending = true);
    if (!await isConnectedToInternet()) {
      setState(() => isSending = false);
      if (!context.mounted) return;
      showNoConnectionMessage(context);
      return;
    }

    setState(() => isSending = true);
    final user = SQLiteService.instance.getUser();
    final idDocument = await service.uploadDocument(
      file: File(pickedFile!.path!),
      filename: filenameController.text,
      classe: selectedClasse,
      subject: subjectController.text,
      year: int.tryParse(yearController.text) ?? 0,
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
      year: int.tryParse(yearController.text) ?? 0,
      classe: selectedClasse,
      subject: subjectController.text,
      categorie: selectedCategory,
    );
    GetIt.I<DocumentViewModel>().addDocument(doc);

    setState(() => isSending = false);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Fichier envoyé')));
  }

  void _showAlert(String title, BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDarkModeNotifier.value;
    final width = MediaQuery.of(context).size.width;
    final inset = Responsive.isDesktop(context) ? width * 0.3 : width * 0.22;

    return AlertDialog(
      // shape: RoundedRectangleBorder(side: BorderSide(width: 700)),
      // insetPadding: EdgeInsets.symmetric(horizontal: inset, vertical: 24),
      contentPadding: EdgeInsets.symmetric(vertical: 40, horizontal: 50),
      backgroundColor:
          isDark
              ? AppColors.darkSecondarySystemBackground
              : AppColors.lightSystemBackground,
      title: const Icon(
        FontAwesomeIcons.cloudArrowUp,
        size: 48,
        color: AppColors.primaryColor,
      ),
      content: SingleChildScrollView(
        child: Column(
          spacing: 7,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final input = textEditingValue.text;
                if (input.isEmpty) {
                  return const <String>[];
                }
                return documents
                    .map((d) => d['subject'] as String)
                    .where(
                      (s) => s.toLowerCase().contains(input.toLowerCase()),
                    );
              },
              fieldViewBuilder: (
                BuildContext context,
                TextEditingController textController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted,
              ) {
                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Matière'),
                  onSubmitted: (_) => onFieldSubmitted(),
                );
              },
              onSelected: (String selection) {
                subjectController.text = selection;
              },
            ),

            TextField(
              controller: filenameController,
              decoration: const InputDecoration(labelText: 'Nom du fichier'),
            ),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Année'),
            ),

            Row(
              children: [
                Text("Classe"),
                Spacer(),
                DropdownButton<String>(
                  value: selectedClasse,
                  items:
                      classes
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => selectedClasse = v!),
                ),
              ],
            ),
            Row(
              children: [
                Text("Categorie"),
                Spacer(),
                DropdownButton<String>(
                  value: selectedCategory,
                  items:
                      categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v!),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                // minimumSize: const Size(200, 40),
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
                // minimumSize: const Size(200, 40),
              ),
              onPressed: () => isSending ? null : _submit(context),
              child: const Text(
                'Envoyer',
                style: TextStyle(color: Colors.white),
              ),
            ),
            // SizedBox(height: 8),
            if (isSending) customLinearProgressSending(progress),
          ],
        ),
      ),
    );
  }
}
