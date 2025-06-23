import 'package:flutter/material.dart';

class SideBarCategory extends StatelessWidget {
  final String? category;
  final List<Widget> items;

  const SideBarCategory({super.key, this.category, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (category != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: Text(
                category!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ...items,
        ],
      ),
    );
  }
}