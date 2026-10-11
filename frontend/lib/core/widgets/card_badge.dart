import 'package:flutter/material.dart';

class CardBadge extends StatelessWidget {
  final Widget? icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const new({
    super.key,
    this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foregroundColor, size: 16),
            child: icon!,
          ),

          const SizedBox(width: 6),
        ],

        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: foregroundColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
