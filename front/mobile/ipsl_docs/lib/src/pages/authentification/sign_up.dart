import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/notifiers.dart';
import 'package:ipsl_docs/src/pages/authentification/widget/build_textfield.dart';
import 'package:ipsl_docs/src/pages/widgets/actions_button.dart';
import 'package:ipsl_docs/src/pages/authentification/login_page.dart';
import 'package:ipsl_docs/src/widget_tree.dart';
import 'package:page_transition/page_transition.dart';
import '../../view_models/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late UserViewModel userViewModel;
  bool isLoading = false;
  final _formKeySign = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  String? selectedClasse = 'Cpi1';
  bool _obscurePassword = true;

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
  @override
  void initState() {
    super.initState();

    userViewModel = GetIt.I<UserViewModel>();
    // Listen for error messages. I prefer this way to show SnackBars via the initState
    // rather than using a ValueListenableBuilder in the build method to avoid rebuilding
    userViewModel.errorNotifier.addListener(() {
      final message = userViewModel.errorNotifier.value;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.darkSystemBackground,
          ),
        );
        userViewModel.errorNotifier.value = null;
      }
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: ThemeController.isDarkModeNotifier,
        builder: (context, isDark, child) {
          return builMobileSignUpPage(isDark, context);
        },
      ),
    );
  }

  SingleChildScrollView builMobileSignUpPage(
    bool isDark,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 55),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 25,
        children: [
          Text(
            "Creer un compte",
            style: GoogleFonts.poppins(
              //fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          Form(
            key: _formKeySign,
            child: Column(
              spacing: 30,
              children: [
                buildTextField(
                  controller: userNameController,
                  label: "Nom d'utilisateur",
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Veuillez entrer votre nom d'utilisateur"
                              : null,
                  isDark: isDark,
                ),
                buildTextField(
                  controller: passwordController,
                  label: "Mot de passe",
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Veuillez entrer votre mot de pasee'
                              : null,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          Row(
            spacing: 10,
            children: [
              Text("Classe", style: TextStyle(fontSize: 16)),
              DropdownButton<String>(
                style: TextStyle(fontSize: 16),
                // autofocus: true,
                borderRadius: BorderRadius.all(Radius.circular(10)),

                padding: EdgeInsets.symmetric(horizontal: 0),
                value: selectedClasse,
                onChanged: (value) {
                  setState(() {
                    selectedClasse = value;
                  });
                },
                items:
                    classe
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: userViewModel.authState,
            builder: (context, state, child) {
              return AuthButton(
                onPressed: () async {
                  _onSignUpPressed(context);
                },
                child:
                    state == ViewState.loading
                        ? SpinKitThreeBounce(color: Colors.white, size: 25)
                        : Text(
                          "S'inscrire",
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Vous avez deja un compte?  "),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: LoginPage(),
                    ),
                  );
                },
                child: Text(
                  "Se connecter",
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => ThemeController.toggleTheme(),

            icon:
                isDark
                    ? const Icon(Icons.light_mode)
                    : const Icon(Icons.dark_mode),
          ),
        ],
      ),
    );
  }

  Future<void> _onSignUpPressed(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_formKeySign.currentState!.validate()) return;
    await userViewModel.signUp(
      userNameController.text.trim(),
      passwordController.text.trim(),
      selectedClasse!,
    );
    if (userViewModel.authState.value != ViewState.success) return;
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WidgetTree()),
      (route) => false,
    );
  }
}
