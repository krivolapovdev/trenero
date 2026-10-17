import 'package:flutter/material.dart';

class StudentDayCreateTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
