import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/pages/authentification/sign_up.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<Widget> _pages = [
    IntroductionComponent(
      title: "Bienvenue sur Ipsl Docs",
      description:
          "L'app pour centraliser et partager des documents avec toute les promos",
      imagePath: "assets/images/onboarding1.svg",
    ),
    IntroductionComponent(
      title: "Partage des documents",
      description:
          "Cour, TD, devoir... Uploade les en un clic pour aider les autres",
      imagePath: "assets/images/onboarding2.svg",
    ),
    IntroductionComponent(
      title: "Telecharge en un clic",
      description: "Accede aux documents partager par tes camarades",
      imagePath: "assets/images/onboarding3.svg",
    ),
    IntroductionComponent(
      title: "Partage de maniere resposable",
      description:
          "Merci 🙏 de ne pas surcharger la platforme. La capacite du serveur est limitee, et trop de documents inutiles peut gener les autres etudiants",
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SignUpPage();
        },
      ),
    );
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

class IntroductionComponent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const IntroductionComponent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 30,
        children: [
          SvgPicture.asset(imagePath, height: 300),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
