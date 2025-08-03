import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/views/widgets/sidebar.dart';

class SideBarCategoryItem2 extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;
  final SidebarItemStatus status;

  const SideBarCategoryItem2({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  @override
  State<SideBarCategoryItem2> createState() => _SideBarCategoryItem2State();
}

class _SideBarCategoryItem2State extends State<SideBarCategoryItem2> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.status == SidebarItemStatus.active;
    final isHovered = _isHovered && !isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color:
                isActive
                    ? AppColors.primaryColor
                    : isHovered
                    ? const Color.fromARGB(255, 182, 125, 101)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isActive ? Colors.white : Colors.white70,
              ),
              const SizedBox(width: 16),
              Text(
                widget.title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
