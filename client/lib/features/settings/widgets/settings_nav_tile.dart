import 'package:flutter/material.dart';

class SettingsNavTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final Widget trailing;

  const new({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
    this.color,
    this.trailing = const Icon(Icons.chevron_right, color: Colors.black54),
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: leading,
    title: Text(
      title,
      style: TextStyle(fontSize: 16, color: color ?? Colors.black87),
    ),
    trailing: trailing,
    onTap: onTap,
  );
}
