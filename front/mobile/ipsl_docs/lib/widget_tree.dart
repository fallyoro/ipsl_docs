import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/views/home.dart';
import 'package:ipsl_docs/views/profile.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




//List<Widget> pages = [const Home(), const Preference(), const Settings()];
List<Widget> pages = [const Home(), const Profile()];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final PageController _pageController = PageController();
  int _selectedPage = 0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Local Linked',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            backgroundColor:
                isDark
                    ? AppColors.darkSystemBackground
                    : AppColors.lightSystemBackground,

            actions: [
              IconButton(
                onPressed: () {
                  ThemeController.toggleTheme();
                },
                icon: isDark ? Icon(Icons.light_mode) : Icon(Icons.dark_mode),
              ),
              
            ],
          ),
         
          bottomNavigationBar: SalomonBottomBar(
            backgroundColor: isDark ? Colors.black38 : Colors.white,
            currentIndex: _selectedPage,
            //selectedItemColor:
                //isDark ? Colors.white : AppColors.vertProfondOrganique,
            //unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
            onTap: (value) {
              setState(() {
                _selectedPage = value;
              });

              _pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 300),
                curve: Curves.decelerate,
              );
            },
            items: [
              SalomonBottomBarItem(
           
                icon: Icon(FontAwesomeIcons.house, size: 30),
                title: Text('Accueil'),
                selectedColor: AppColors.primaryColor,
              ),
              SalomonBottomBarItem(
           
                icon: Icon(FontAwesomeIcons.house, size: 30),
                title: Text('Profile'),
              
              ),
             
            ],
          ),

          body: PageView(
            //physics: const AlwaysScrollableScrollPhysics(),
            physics: const ScrollPhysics(),
            controller: _pageController,
            onPageChanged: (int index) {
              setState(() {
                _selectedPage = index;
              });
            },
            children: pages,
          ),
        );
      },
    );
  }
}
