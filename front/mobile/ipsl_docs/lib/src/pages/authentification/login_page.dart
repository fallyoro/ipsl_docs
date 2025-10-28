import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/pages/authentification/widget/build_textfield.dart';
import 'package:ipsl_docs/src/pages/widgets/actions_button.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:ipsl_docs/src/pages/authentification/sign_up.dart';
import 'package:ipsl_docs/src/widget_tree.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKeyLog = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = false;
  late DocumentViewModel documentViewModel;
  late UserViewModel userViewModel;

  @override
  void initState() {
    super.initState();
    userViewModel = GetIt.I<UserViewModel>();
    documentViewModel = GetIt.I<DocumentViewModel>();
    // Listen for error messages. I prefer this way to show SnackBars via the initState
    // rather than using a ValueListenableBuilder in the build method to avoid rebuilding
    userViewModel.errorNotifier.addListener(() {
      final message = userViewModel.errorNotifier.value;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.darkSecondarySystemBackground,
          ),
        );
        userViewModel.errorNotifier.value = null;
      }
    });
  }

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 55),
        child: Column(
          spacing: 25,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Se connecter", style: GoogleFonts.poppins(fontSize: 30)),

            Form(
              key: _formKeyLog,
              child: Column(
                spacing: 30,
                children: [
                  buildTextField(
                    controller: userNameController,
                    label: "Nom d'utilisateur",
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Veuillez entrer votre nom utilisateur'
                                : null,
                    isDark: isDark,
                  ),
                  buildTextField(
                    controller: passwordController,
                    label: "Mot de passe",
                    obscure: _obscurePassword,
                    suffix: IconButton(
                      icon:
                      _obscurePassword
                          ? Icon(FontAwesomeIcons.eyeSlash)
                          : Icon(FontAwesomeIcons.eye),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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

            ValueListenableBuilder(
              valueListenable: userViewModel.authState,
              builder: (context, state, child) {
                return AuthButton(
                  onPressed: () async {
                    handleLogin(context);
                  },
                  child:
                      state == ViewState.loading
                          ? SpinKitThreeBounce(color: Colors.white, size: 25)
                          : Text(
                            "Se connecter",
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
                Text("Vous n'avez pas de compte?  "),
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.fade,
                        child: SignUpPage(),
                      ),
                    );
                  },
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_formKeyLog.currentState!.validate()) return;
    await userViewModel.login(
      userNameController.text.trim(),
      passwordController.text.trim(),
    );
    await documentViewModel.syncDocumentFromServer();
    await documentViewModel.loadDocuments();
    if (userViewModel.authState.value != ViewState.success) return;
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WidgetTree()),
      (route) => false,
    );
  }
}
