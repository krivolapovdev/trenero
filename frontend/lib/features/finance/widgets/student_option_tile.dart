import 'package:flutter/material.dart';

class StudentOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const new({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    enabled: enabled,
    title: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    trailing: selected
        ? const Icon(Icons.check, color: Colors.deepPurple)
        : null,
    onTap: onTap,
  );
}
