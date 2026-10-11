import 'package:flutter/material.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class StudentCheckboxTile extends StatelessWidget {
  final StudentSummaryResponse student;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const new({
    super.key,
    required this.student,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: selected,
    onChanged: enabled ? (_) => onToggle() : null,
    title: Text(
      student.fullName,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16),
    ),
    controlAffinity: ListTileControlAffinity.leading,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  );
}
