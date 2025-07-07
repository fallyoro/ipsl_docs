import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home.dart';
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
  final documentViewModel = GetIt.I<DocumentViewModel>();
  TextEditingController filenameController = TextEditingController();
  TextEditingController classeController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  // Controller for year input, expecting integer values
  TextEditingController yearController = TextEditingController();
  // int? get yearValue => int.tryParse(yearController.text);
  String? selectedClasse = 'Cpi1';
  final List<String> classe = [
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
  String? selectedCategory = 'cour';
  final List<String> categories = [
    'cour',
    'tp',
    'devoir',
    'td',
    'tutorat',
    'utile',
  ];
  final PageController _pageController = PageController();
  PlatformFile? pickedFile;
  int _selectedPage = 0;
  String? fileName;
  DocumentServive service = DocumentServive();
  // bool isRailExtended = true;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      pickedFile = result.files.single;
      setState(() {
        fileName = result.files.single.name;
        filenameController.text = result.files.single.name;
      });
    }
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
            shape: CircleBorder(),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => StatefulBuilder(
                      builder:
                          (context, setState) => AlertDialog(
                            // alignment: Alignment.topRight,
                            actionsAlignment: MainAxisAlignment.center,

                            insetPadding: EdgeInsets.symmetric(
                              horizontal:
                                  isDestop
                                      ? screenWidth * 0.3
                                      : screenWidth * 0.22,
                              vertical: 24,
                            ),
                            actionsPadding: EdgeInsets.all(50),
                            iconColor: AppColors.primaryColor,

                            backgroundColor:
                                isDark
                                    ? AppColors.darkSecondarySystemBackground
                                    : AppColors.lightSystemBackground,
                            icon: Icon(FontAwesomeIcons.upload),
                            title: Text('Envoyer un document'),
                            actions: [
                              TextField(
                                controller: filenameController,

                                decoration: const InputDecoration(
                                  labelText: "Non du fichier",
                                  constraints: BoxConstraints(maxWidth: 500),
                                ),
                              ),
                              TextField(
                                controller: yearController,

                                decoration: const InputDecoration(
                                  labelText: "annee",
                                  constraints: BoxConstraints(maxWidth: 500),
                                ),
                              ),
                              TextField(
                                controller: subjectController,

                                decoration: const InputDecoration(
                                  labelText: "matiere",
                                  constraints: BoxConstraints(maxWidth: 500),
                                ),
                              ),
                              Row(
                                // mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Classe"),
                                  DropdownButton<String>(
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),

                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),

                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    value: selectedClasse,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedClasse = value;
                                      });
                                    },
                                    items:
                                        classe
                                            .map<DropdownMenuItem<String>>(
                                              (String value) =>
                                                  DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Categorie'),
                                  SizedBox(width: 20),
                                  DropdownButton<String>(
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    value: selectedCategory,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value;
                                      });
                                    },
                                    items:
                                        categories
                                            .map(
                                              (e) => DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                ),
                                onPressed: _pickFile,
                                child: const Text(
                                  "Choisir un fichier",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  // minimumSize: const Size(200, 40),
                                ),

                                onPressed: () async {
                                  if (pickedFile == null ||
                                      fileName == null ||
                                      selectedClasse == null ||
                                      selectedCategory == null ||
                                      subjectController.text.isEmpty ||
                                      yearController.text.isEmpty) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text('Champs manquants'),
                                            content: Text(
                                              'Veuillez remplir tous les champs et sélectionner un fichier.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                    );
                                    return;
                                  }
                                  var userData =
                                      SQLiteService.instance.getUser();
                                  String? idDocument = await service
                                      .uploadDocument(
                                        file: File(pickedFile!.path!),
                                        filename: fileName!,
                                        classe: selectedClasse!,
                                        subject: subjectController.text,
                                        year:
                                            int.tryParse(yearController.text) ??
                                            0,
                                        categorie: selectedCategory!,
                                        userId: userData['id'],
                                      );

                                  Document doc = Document(
                                    id: idDocument!,
                                    idUploader: userData['id'],
                                    filename: fileName!,
                                    year:
                                        int.tryParse(yearController.text) ?? 0,
                                    classe: selectedClasse!,
                                    subject: subjectController.text,
                                    categorie: selectedCategory!,
                                  );
                                  documentViewModel.addDocument(doc);
                                  documentViewModel.documents.value = [
                                    ...documentViewModel.documents.value,
                                    doc,
                                  ];

                                  Navigator.pop(context);
                                  if (idDocument.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Fichier envoyer avec succes. Merci de votre contribution",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor:
                                            AppColors
                                                .darkSecondarySystemBackground,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Envoie echoue. Veillez verifier votre connexion internet",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor:
                                            AppColors
                                                .darkSecondarySystemBackground,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  "Envoyer",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),
              );
            },
            child: Icon(FontAwesomeIcons.plus),
          ),
          appBar: AppBar(
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
          ),

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
}
