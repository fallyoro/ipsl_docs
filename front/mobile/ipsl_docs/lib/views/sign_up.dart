import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
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
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: EdgeInsets.all(30),
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
                      "Bienvenue sur Ipsl Docs",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        color: isDark ? AppColors.darkLabel : Colors.black,
                      ),
                    ),
                    Container(height: 30),
                    TextField(
                      controller: userNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Nom utilisateur",
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Mot de passe",
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<String>(
                      style: TextStyle(fontSize: 16),
                      // autofocus: true,
                      borderRadius: BorderRadius.all(Radius.circular(10)),

                      padding: EdgeInsets.symmetric(horizontal: 20),
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
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: 60),
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
                        if (userNameController.text.isEmpty ||
                            emailController.text.isEmpty) {
                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Champs manquants'),
                                  content: Text(
                                    'Veuillez remplir tous les champs',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                          );
                          return;
                        }
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
                        if (userData!.isNotEmpty) {
                          auth.login(
                            emailController.text,
                            passwordController.text,
                          );
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
                            MaterialPageRoute(
                              builder: (context) => WidgetTree(),
                            ),
                          );

                          if (userData.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Creation de compte echouer",
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor:
                                    AppColors.darkSecondarySystemBackground,
                              ),
                            );
                          }
                        }
                      },
                      child:
                          isLoding
                              ? CircularProgressIndicator()
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
