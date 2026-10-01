import 'package:flutter/cupertino.dart';

class TransactionTileInfo {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? initials;
  final Color backgroundColor;

  const new({
    required this.title,
    required this.subtitle,
    this.icon,
    this.initials,
    required this.backgroundColor,
  });
}
