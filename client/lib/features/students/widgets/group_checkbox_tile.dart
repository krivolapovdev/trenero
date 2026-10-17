import 'package:flutter/material.dart';
import 'package:phone/generated/models/group_summary_response.dart';

class GroupCheckboxTile extends StatelessWidget {
  final GroupSummaryResponse group;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const new({
    super.key,
    required this.group,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: selected,
    onChanged: enabled ? (_) => onToggle() : null,
    title: Text(
      group.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  );
}
