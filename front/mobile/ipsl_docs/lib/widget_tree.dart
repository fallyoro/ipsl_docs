import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/views/home/home.dart';
import 'package:ipsl_docs/views/profile_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/Responsive.dart';

List<Widget> pages = [Home(), const Profile()];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final PageController _pageController = PageController();
  int _selectedPage = 0;

  void _onItemSelected(int index) {
    setState(() => _selectedPage = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.decelerate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        final isMobile = Responsive.isMobile(context);
        final isTablet = Responsive.isTablet(context);
        double screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          //  appBar: buildAppbarWidgetTree(isDark),
          body:
                   PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged:
                        (index) => setState(() => _selectedPage = index),
                    children: pages,
                  ),
          bottomNavigationBar:
                   SalomonBottomBar(
                    selectedItemColor:
                        isDark ? Colors.white : AppColors.primaryColor,
                    unselectedItemColor:
                        isDark ? Colors.grey : Colors.grey.shade600,
                    backgroundColor:
                        isDark
                            ? AppColors.darkSecondarySystemBackground
                            : Colors.white,
                    currentIndex: _selectedPage,
                    onTap: _onItemSelected,
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.house, size: 23),
                        title: const Text('Accueil'),
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.userLarge, size: 23),
                        title: const Text('Profil'),
                      ),
                    ],
                  )
        );
      },
    );
  }
}
