import 'package:flutter/material.dart';

import '../../../core/constant.dart';

class BreadcrumbsCustom extends StatelessWidget {
  final List<String> items;
  final void Function(int index)? onTap;
  final TextStyle? textStyle;
  final TextStyle? lastItemStyle;
  final Widget separator;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const BreadcrumbsCustom({
    super.key,
    required this.items,
    this.onTap,
    this.textStyle,
    this.lastItemStyle,
    this.separator = const Icon(
      Icons.chevron_right,
      size: 16,
      color: Colors.grey,
    ),
    this.spacing = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Si pas ou un seul élément, on affiche juste le dernier (ou rien)
    if (items.isEmpty) {
      return SizedBox.shrink();
    }

    final defaultStyle =
        textStyle ??
        TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16);
    final defaultLastStyle =
        lastItemStyle ??
        TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        );

    return SingleChildScrollView(
      reverse: true,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: padding,
        child: Row(
          children: List.generate(items.length * 2 - 1, (index) {
            // on intercale séparateur entre les items
            if (index.isEven) {
              int itemIndex = index ~/ 2;
              bool isLast = itemIndex == items.length - 1;
              return GestureDetector(
                onTap:
                    (!isLast && onTap != null) ? () => onTap!(itemIndex) : null,
                child: Text(
                  items[itemIndex],
                  style: isLast ? defaultLastStyle : defaultStyle,
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: separator,
              );
            }
          }),
        ),
      ),
    );
  }
}
