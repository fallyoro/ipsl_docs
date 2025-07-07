import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/global.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/user.dart';
import 'package:ipsl_docs/view_models/user.dart';
import 'package:ipsl_docs/views/sign_up.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';

final userViewModel = getIt<UserViewModel>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoding = false;

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
                        setState(() {
                          isLoding = true;
                        });
                        var userInfo = await auth.login(
                          emailController.text,
                          passwordController.text,
                        );
                        setState(() {
                          isLoding = false;
                        });
                        User user = User(
                          id: userInfo?['id'],
                          userName: userInfo?['user_name'],
                          email: userInfo?['email'],
                        );
                        if (userInfo!.isNotEmpty) {
                          userViewModel.addUser(user);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WidgetTree(),
                            ),
                          );
                          if (userInfo.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Login echoue echouer",
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
}
