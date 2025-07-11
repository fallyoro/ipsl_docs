import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/user.dart';
import 'package:ipsl_docs/services/auth_service.dart';
import 'package:ipsl_docs/services/token_service.dart';
import 'package:ipsl_docs/stokage_service.dart';
import 'package:ipsl_docs/views/login_page.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

TokenService tokens = TokenService();

final options = BaseOptions(
  baseUrl: 'http://$host:$port/auth',
  connectTimeout: Duration(minutes: 1),
  receiveTimeout: Duration(minutes: 1),
);
final dio = Dio(options);
final auth = AuthService(dio: dio, tokens: tokens);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SignUpPage> {
  bool isLoding = false;
  final _formKeySign = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: ThemeController.isDarkModeNotifier,
        builder: (context, isDark, child) {
          return Center(
            child: Container(
              width: 550,
              height: 600,
              padding: const EdgeInsets.all(0),
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkOpaqueSeparator : Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bienvenue sur Ipsl Docs",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: isDark ? AppColors.darkLabel : Colors.black,
                      ),
                    ),
                    Container(height: 30),
                    Form(
                      key: _formKeySign,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: userNameController,
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? "Veuillez entrer votre nom d'utilisateur"
                                        : null,
                            decoration: InputDecoration(
                              labelText: "Nom utillisateur",
                              // suffixIcon: Icon(FontAwesomeIcons.word),)
                            ),
                          ),
                          TextFormField(
                            controller: emailController,

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

                    const SizedBox(height: 20),
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
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 30),
                    FilledButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),

                        backgroundColor: AppColors.primaryColor,
                      ),
                      onPressed: () async {
                        final bool isConnected = await isConnectedToInternet();
                        if (isConnected == false) {
                          if (!context.mounted) return;
                          showNoConnectionMessage(context);
                          return;
                        }
                        if (!_formKeySign.currentState!.validate()) return;

                        setState(() {
                          isLoding = true;
                        });
                        final userData = await auth.signUp(
                          userNameController.text,
                          emailController.text,
                          passwordController.text,
                          selectedClasse!,
                        );
                        setState(() {
                          isLoding = false;
                        });

                        auth.login(
                          emailController.text,
                          passwordController.text,
                        );

                        if (userData['error'] != null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                userData['error'],
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor:
                                  AppColors.darkSecondarySystemBackground,
                            ),
                          );
                          return;
                        }

                        User user = User(
                          id: userData['id'],
                          userName: userNameController.text,
                          email: emailController.text,
                        );
                        userViewModel.addUser(user);
                        StorageService.setBool("isLoged", true);
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WidgetTree()),
                        );
                      },
                      child:
                          isLoding
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Suivant",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                ),
                              ),
                    ),
                    SizedBox(height: 20),
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
