import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/views/home.dart';
import 'package:ipsl_docs/views/profile.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/Responsive.dart';



List<Widget> pages = [
  Home(),
  const Profile(),
  const Center(child: Text("Paramètres")),
];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final PageController _pageController = PageController();
  int _selectedPage = 0;
  bool isRailExtended = true;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        final isMobile = Responsive.isMobile(context);
        final isTablet = Responsive.isTablet(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Ipsl Docs',
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
                icon:
                    isDark
                        ? const Icon(Icons.light_mode)
                        : const Icon(Icons.dark_mode),
              ),
            ],
          ),

      
          drawer:
              isMobile || isTablet
                  ? Drawer(
                    backgroundColor:
                        isDark
                            ? AppColors.darkSystemBackground
                            : AppColors.lightSystemBackground,
                    child: ListView(
                      children: [
                        const DrawerHeader(
                          child: Text("Menu", style: TextStyle(fontSize: 24)),
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.house),
                          title: const Text("Accueil"),
                          onTap: () {
                            setState(() => _selectedPage = 0);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.userLarge),
                          title: const Text("Profil"),
                          onTap: () {
                            setState(() => _selectedPage = 1);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(FontAwesomeIcons.gear),
                          title: const Text("Paramètres"),
                          onTap: () {
                            setState(() => _selectedPage = 2);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                  : null,

          body:
              isMobile || isTablet
                  ? PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedPage = index);
                    },
                    children: pages,
                  )
                  : Row(
                    children: [
                      NavigationRail(
                        extended: isRailExtended,
                        selectedIndex: _selectedPage,
                        onDestinationSelected: (index) {
                          setState(() => _selectedPage = index);
                        },
                        labelType: NavigationRailLabelType.none,
                        backgroundColor:
                            isDark
                                ? AppColors.darkSystemBackground
                                : AppColors.lightSystemBackground,
                        elevation: 4,
                        selectedIconTheme: IconThemeData(
                          color: isDark ? Colors.white : Colors.black,
                          size: 28,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: Colors.grey,
                          size: 24,
                        ),
                        selectedLabelTextStyle: TextStyle(
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(FontAwesomeIcons.house, size: 30),
                            label: Text('Accueil'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(FontAwesomeIcons.userLarge),
                            label: Text('Profil'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(FontAwesomeIcons.gear),
                            label: Text('Paramètres'),
                          ),
                        ],
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(child: pages[_selectedPage]),
                    ],
                  ),

          
          bottomNavigationBar:
              isMobile
                  ? SalomonBottomBar(
                    backgroundColor:
                        isDark
                            ? AppColors.darkSecondarySystemBackground
                            : Colors.white,
                    currentIndex: _selectedPage,

                    onTap: (value) {
                      setState(() => _selectedPage = value);
                      _pageController.animateToPage(
                        value,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.decelerate,
                      );
                    },
                    items: [
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.house, size: 30),
                        title: const Text('Accueil'),
                        selectedColor: isDark ? Colors.white : Colors.black,
                        //unselectedColor: isDark ? Colors.grey : Colors.grey,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.userLarge),
                        title: const Text('Profil'),
                        selectedColor: isDark ? Colors.white : Colors.black,
                      ),
                      SalomonBottomBarItem(
                        icon: const Icon(FontAwesomeIcons.gear),
                        title: const Text('Paramètres'),
                        selectedColor: isDark ? Colors.white : Colors.black,
                      ),
                    ],
                  )
                  : null,
        );
      },
    );
  }
}
