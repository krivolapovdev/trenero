import 'package:flutter/material.dart';

class FilterCheckboxTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onToggle;

  const new({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: isSelected,
    onChanged: (_) => onToggle(),
    title: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: EdgeInsets.zero,
    dense: true,
  );
}
