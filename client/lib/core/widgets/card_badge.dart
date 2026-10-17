import 'package:flutter/material.dart';
import 'package:phone/core/constants/app_radius.dart';

class CardBadge extends StatelessWidget {
  static const double _paddingHorizontal = 10;
  static const double _paddingVertical = 5;
  static const double _iconSize = 16;
  static const double _iconGap = 6;

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
    padding: const EdgeInsets.symmetric(
      horizontal: _paddingHorizontal,
      vertical: _paddingVertical,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: AppRadius.xlAll,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: foregroundColor, size: _iconSize),
            child: icon!,
          ),

          const SizedBox(width: _iconGap),
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
