import 'package:flutter/material.dart';
import 'package:ipsl_docs/src/core/constant.dart';

NavigationDrawer buildDrawer() {
  return NavigationDrawer(
    backgroundColor: AppColors.lightSystemBackground,

    children: [
      // header personnalisé
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Text(
          'Menu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      NavigationDrawerDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Accueil'),
      ),
      NavigationDrawerDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Profil'),
      ),
      NavigationDrawerDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Paramètres'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Text("Recent"),
      ),
    ],
  );
}
