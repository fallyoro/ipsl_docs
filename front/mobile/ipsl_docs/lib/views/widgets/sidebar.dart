import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/views/widgets/sidebar_categorie.dart';
import 'package:ipsl_docs/views/widgets/sidebar_categorie_item.dart';

enum SidebarItemStatus { active, hovered, inactive }

class SideBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final double width;

  const SideBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: AppColors.darkSecondarySystemBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          SideBarCategory(
            category: 'MAIN',
            items: [
              SideBarCategoryItem2(
                icon: FontAwesomeIcons.house,
                title: 'Accueil',
                status:
                    selectedIndex == 0
                        ? SidebarItemStatus.active
                        : SidebarItemStatus.inactive,
                onTap: () => onItemSelected(0),
              ),
              SideBarCategoryItem2(
                icon: FontAwesomeIcons.userLarge,
                title: 'Profile',
                status:
                    selectedIndex == 1
                        ? SidebarItemStatus.active
                        : SidebarItemStatus.inactive,
                onTap: () => onItemSelected(1),
              ),
              SideBarCategoryItem2(
                icon: FontAwesomeIcons.gear,
                title: 'Parametre',
                status:
                    selectedIndex == 2
                        ? SidebarItemStatus.active
                        : SidebarItemStatus.inactive,
                onTap: () => onItemSelected(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
