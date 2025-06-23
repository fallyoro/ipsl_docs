import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/global.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/views/login_page.dart';
import 'package:ipsl_docs/widget_tree.dart';

final userViewModel = getIt<UserViewModel>();

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  String? selectedClasse = 'cpi1';
  final List<String> classe = ['cpi1', 'cpi2', 'ing1', 'ing2', 'ing3'];

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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WidgetTree()),
                        );
                      },
                      child: const Text(
                        "Suivant",
                        style: TextStyle(color: Colors.white, fontSize: 26),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text(
                        "Se connecter",
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
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
