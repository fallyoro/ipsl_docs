import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/pages/profile/edit_profile_page.dart';
import 'package:ipsl_docs/src/view_models/document.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:ipsl_docs/src/widget_tree.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../authentification/widget/introduction_component.dart';
import '../authentification/widget/login_bottomsheet.dart';
import '../authentification/widget/overlay_message.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late UserViewModel userViewModel;
  late VoidCallback listener;
  late DocumentViewModel documentViewModel;
  final List<Widget> _pages = [
    IntroductionComponent(
      title: "Bienvenue sur IPSL Docs",
      description:
          "L'app pour centraliser et partager des documents avec toutes les promos.",
      imagePath: "assets/images/onboarding1.svg",
    ),
    IntroductionComponent(
      title: "Partage de documents",
      description:
          "Cours, TD, devoirs... Upload-les en un clic pour aider les autres.",
      imagePath: "assets/images/onboarding2.svg",
    ),
    IntroductionComponent(
      title: "Télécharge en un clic",
      description: "Accède aux documents partagés par tes camarades.",
      imagePath: "assets/images/onboarding3.svg",
    ),
    IntroductionComponent(
      title: "Partage de manière responsable",
      description:
          "Merci 🙏 de ne pas surcharger la plateforme. La capacité du serveur est limitée, et trop de documents inutiles peut gêner les autres étudiants.",
      imagePath: "assets/images/onboarding4.svg",
    ),
  ];

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onFinish() {
    showLoginBottomSheet(context);
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

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
        showTopOverlayMessage(context, message);
        userViewModel.errorNotifier.value = null;
      }
    });
    userViewModel.authState.addListener(() {
      if (userViewModel.authState.value == ViewState.success) {
        _navigateToEditProfile();
      }
    });
  }

  void _navigateToEditProfile() {
    final user = userViewModel.userNotifier.value!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EditProfilePage(
              userName: user.userName,
              userClass: user.classe,
              onSucces: () {
                _navigateToWidgetTree(); // Navigue vers ton widgetTree après succès
              },
            ),
      ),
    );
  }

  // Fonctions privées pour la navigation
  void _navigateToWidgetTree() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WidgetTree()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          _currentIndex == _pages.length - 1
              ? SizedBox.shrink()
              : Positioned(
                bottom: 20,
                left: 20,
                child: TextButton(
                  child: TextButton(
                    child: Text(
                      "Passer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),

                    onPressed: () {
                      _skip();
                    },
                  ),
                  onPressed: () {},
                ),
              ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              child: Text(
                _currentIndex == _pages.length - 1 ? "Commencer" : "Suivant",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              onPressed: () {
                _onNext();
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,

            bottom: 40,
            child: Center(
              child: AnimatedSmoothIndicator(
                count: _pages.length,
                activeIndex: _currentIndex,
                effect: JumpingDotEffect(
                  dotWidth: 12,
                  dotHeight: 12,
                  activeDotColor: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
