import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/user.dart';
import 'package:ipsl_docs/stokage_service.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/views/sign_up.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';
import 'package:get_it/get_it.dart';

final userViewModel = GetIt.I<UserViewModel>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKeyLog = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoding = false;
  bool _obscurePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSecondarySystemBackground
              : Colors.white,
      body: ValueListenableBuilder(
        valueListenable: ThemeController.isDarkModeNotifier,
        builder: (context, isDark, child) {
          if ((Theme.of(context).platform == TargetPlatform.android ||
              Theme.of(context).platform == TargetPlatform.iOS)) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 55),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Se connecter",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                      color: isDark ? AppColors.darkLabel : Colors.black,
                    ),
                  ),
                  Container(height: 30),

                  Form(
                    key: _formKeyLog,
                    child: Column(
                      spacing: 30,
                      children: [
                        TextFormField(
                          controller: userNameController,

                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Veuillez entrer votre nom utilisateur'
                                      : null,
                          decoration: InputDecoration(
                            labelText: "Nom d'utilisateur",
                            filled: true,
                            fillColor:
                                isDark
                                    ? AppColors.darkSystemBackground
                                    : AppColors.lightSecondarySystemBackground,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _obscurePassword ? false : true,
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'Veuillez entrer votre mot de pasee'
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
                            labelText: "Mot de passe",
                            suffixIcon: IconButton(
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 60),
                  ActionButton(
                    onPressed: () async {
                      handleLogin(context);
                    },
                    action: "Se connecter",
                    height: 50,
                    width: 300,
                    isLoading: isLoding,
                    actionFontSize: 19,
                  ),

                  SizedBox(height: 20),
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
            );
          }
          return Center(
            child: Container(
              width: 550,
              height: 600,
              padding: const EdgeInsets.all(0),
              child: Container(
                padding: EdgeInsets.all(35),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkOpaqueSeparator : Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Se connecter",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: isDark ? AppColors.darkLabel : Colors.black,
                      ),
                    ),
                    Container(height: 30),

                    Form(
                      key: _formKeyLog,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: userNameController,

                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Veuillez entrer votre email'
                                        : null,
                            decoration: InputDecoration(
                              labelText: "Email",
                              suffixIcon: Icon(FontAwesomeIcons.envelope),
                            ),
                          ),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword ? false : true,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Veuillez entrer votre mot de pasee'
                                        : null,
                            decoration: InputDecoration(
                              labelText: "Mot de passe",
                              suffixIcon: IconButton(
                                icon:
                                    _obscurePassword
                                        ? Icon(FontAwesomeIcons.eye)
                                        : Icon(FontAwesomeIcons.eyeSlash),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                    ActionButton(
                      onPressed: () async {
                        handleLogin(context);
                      },
                      action: "Se connecter",
                      height: 50,
                      width: 300,
                      isLoading: isLoding,
                      actionFontSize: 19,
                    ),
                    SizedBox(height: 20),
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
            ),
          );
        },
      ),
    );
  }

  Future<void> handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final bool isConnected = await isConnectedToInternet();
    if (!isConnected) {
      if (!context.mounted) return; // Vérifie que widget est toujours actif
      showNoConnectionMessage(context);
      return;
    }
    if (!_formKeyLog.currentState!.validate()) return;

    setState(() => isLoding = true);
    final userInfo = await auth.login(
      userNameController.text,
      passwordController.text,
    );
    if (!context.mounted) return; // essentiel avant de setState/post-await
    setState(() => isLoding = false);

    if (userInfo['error'] != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userInfo['error'],
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.darkSecondarySystemBackground,
        ),
      );
      return;
    }

    final user = User(
      id: userInfo['id'],
      userName: userInfo['user_name'],
      classe: userInfo['classe'],
      numberContribution: int.tryParse(userInfo['number_contribution'])!,
    );
    await StorageService.setBool("isLoged", true);
    userViewModel.addUser(user);

    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => WidgetTree()));
  }
}
