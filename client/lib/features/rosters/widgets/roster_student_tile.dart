import 'package:flutter/material.dart';
import 'package:phone/features/students/pages/student_page.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class RosterStudentTile extends StatelessWidget {
  final StudentResponse student;
  final StudentSummaryResponse? fullSummary;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRemove;
  final bool enabled;
  final BorderRadius? borderRadius;

  const new({
    super.key,
    required this.student,
    this.onEdit,
    this.onDelete,
    this.onRemove,
    this.fullSummary,
    this.enabled = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  StudentSummaryResponse get _effectiveSummary =>
      fullSummary ??
      StudentSummaryResponse(
        id: student.id,
        fullName: student.fullName,
        createdAt: student.createdAt,
        free: student.free,
        birthdate: student.birthdate,
        note: student.note,
        phone: student.phone,
        statuses: const [],
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = student.note ?? fullSummary?.note;
    final hasNote = note != null && note.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      child: ListTile(
        shape: borderRadius != null
            ? RoundedRectangleBorder(borderRadius: borderRadius!)
            : null,
        title: Text(
          student.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: hasNote
            ? Text(
                note.trim(),
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            : null,
        trailing: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93)),
                onPressed: enabled ? onEdit : null,
              )
            : null,
        onTap: enabled
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentPage(student: _effectiveSummary),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
