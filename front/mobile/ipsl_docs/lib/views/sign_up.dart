import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/user.dart';
import 'package:ipsl_docs/services/auth_service.dart';
import 'package:ipsl_docs/stokage_service.dart';
import 'package:ipsl_docs/views/login_page.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:page_transition/page_transition.dart';



final options = BaseOptions(
  baseUrl: 'http://$host:$port/auth',
  connectTimeout: Duration(seconds: 10),
  // receiveTimeout: Duration(minutes: 1),
);
final dio = Dio(options);
final auth = AuthService(dio: dio);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoding = false;
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
  Widget build(BuildContext context) {
    bool isMobileDevice =
        Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSecondarySystemBackground
              : Colors.white,
      body: ValueListenableBuilder(
        valueListenable: ThemeController.isDarkModeNotifier,
        builder: (context, isDark, child) {
          if (isMobileDevice) {
            return builMobileSignUpPage(isDark, context);
          }
          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: 550,
                height: 600,
                padding: const EdgeInsets.all(0),
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.darkSeparator : Colors.black,
                      width: 2.5,
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
                                            isDark
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 30),
                      ActionButton(
                        isLoading: isLoding,
                        action: "S'inscrire",
                        onPressed: () async {
                          _onSignUpPressed(context);
                        },
                        width: 300,
                        height: 60,
                        actionFontSize: 22,
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
            ),
          );
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

        children: [
          Text(
            "Bienvenue sur Ipsl Docs",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 36,
              color: isDark ? AppColors.darkLabel : Colors.black,
            ),
          ),
          Container(height: 30),
          Form(
            key: _formKeySign,
            child: Column(
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
          const SizedBox(height: 30),
          ActionButton(
            onPressed: () async {
              _onSignUpPressed(context);
            },
            action: "S'inscrire",
            height: 50,
            width: 300,
            isLoading: isLoding,
            actionFontSize: 19,
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
    final bool isConnected = await isConnectedToInternet();
    if (!isConnected) {
      if (!context.mounted) return;
      showNoConnectionMessage(context);
      return;
    }
    if (!_formKeySign.currentState!.validate()) return;

    setState(() => isLoding = true);
    final userData = await auth.signUp(
      userNameController.text,

      passwordController.text,
      selectedClasse!,
    );
    setState(() => isLoding = false);

    auth.login(userNameController.text, passwordController.text);

    if (userData['error'] != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userData['error'],
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.darkSecondarySystemBackground,
        ),
      );
      return;
    }

    User user = User(
      id: userData['id'],
      userName: userNameController.text,
      classe: selectedClasse!,
      numberContribution: userData['number_contribution'],
    );
    userViewModel.addUser(user);
    StorageService.setBool("isLoged", true);
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => WidgetTree()));
  }
}

class ActionButton extends StatelessWidget {
  final bool isLoading;
  final String action;
  final double actionFontSize;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const ActionButton({
    super.key,
    required this.isLoading,
    required this.action,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.actionFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: ElevatedButton.styleFrom(
        // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        fixedSize: Size(width, height),
        backgroundColor: AppColors.primaryColor,
        disabledBackgroundColor: AppColors.primaryColor,
      ),
      onPressed: isLoading ? null : onPressed,
      child:
          isLoading
              ? const SpinKitThreeBounce(color: Colors.white, size: 25)
              : Text(
                action,
                style: TextStyle(color: Colors.white, fontSize: actionFontSize),
              ),
    );
  }
}
