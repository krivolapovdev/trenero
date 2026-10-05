import 'package:flutter/widgets.dart';

class StudentBadgeData {
  final String id;
  final Widget? icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const new({
    required this.id,
    this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}
