import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/services/auth_service.dart';
import 'package:ipsl_docs/src/view_models/user.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userClass;
  const EditProfilePage({
    super.key,
    required this.userName,
    required this.userClass,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final UserViewModel userViewModel;

  late final UserService userService;
  final _formKeyEdit = GlobalKey<FormState>();
  late TextEditingController userNameController;
  late String selectedClasse = 'Cpi1';

  final List<String> classes = [
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userViewModel = GetIt.instance<UserViewModel>();
    userNameController = TextEditingController(text: widget.userName);
    selectedClasse = widget.userClass;
    userService = GetIt.instance<UserService>();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isMobileDevice =
        Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;
    if (isMobileDevice) {
      return Scaffold(
        appBar: AppBar(title: Text("Profil"), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: _formKeyEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 30,
                  children: [
                    TextFormField(
                      controller: userNameController,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? "Veuillez entrer votre nom d'utilisateur"
                                  : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        filled: true,
                        fillColor:
                            isDark
                                ? AppColors.darkSystemBackground
                                : AppColors.lightSecondarySystemBackground,
                        labelText: "Nom d'utillisateur",

                        // suffixIcon: Icon(FontAwesomeIcons.word),)
                      ),
                    ),

                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Row(
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
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
                onPressed: () async {
                  await editProfile(context);
                },
                child: Text("Modifier", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }
    return Text("Desktop");
  }

  Future<void> editProfile(BuildContext context) async {
    final bool isConnected = await isConnectedToInternet();
    if (!isConnected) {
      if (!context.mounted) return; // check if the widget is active
      showNoConnectionMessage(context);
      return;
    }

    userService.editProfile(
      selectedClasse,
      userViewModel.userNotifier.value!.id,
      userNameController.text,
    );
    await userViewModel.updateUser(userNameController.text, selectedClasse);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Profile modifier avec succes')));
    Navigator.pop(context, true);
  }
}
