import 'package:flutter/material.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/pages/attendance_mark.dart';
import 'package:phone/features/groups/pages/lesson_ui.dart';
import 'package:phone/features/groups/pages/modifiers_text.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/generated/models/visit_type.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentAttendanceTile extends StatelessWidget {
  final GroupStudentSummaryResponse student;
  final int number;
  final bool canEdit;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final LessonAttendance? attendance;
  final bool unmarked;

  const new({
    super.key,
    required this.student,
    required this.number,
    required this.canEdit,
    required this.onToggle,
    required this.onLongPress,
    this.attendance,
    this.unmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFree = attendance?.type == VisitType.free;
    final isPresent = attendance?.status == VisitStatus.present;

    final modifiers = <String>[
      if (attendance?.status == VisitStatus.excused) context.t.lessons.excused,
      if (attendance?.type == VisitType.free) context.t.lessons.freeLesson,
    ];

    return InkWell(
      onTap: canEdit && !unmarked ? onToggle : null,
      onLongPress: canEdit ? onLongPress : null,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: SizedBox(
          width: 24,
          child: Text(
            '$number.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          student.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            decoration: unmarked ? TextDecoration.lineThrough : null,
            color: unmarked ? colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: modifiers.isEmpty
            ? null
            : ModifiersText(modifiers: modifiers),
        trailing: unmarked
            ? null
            : canEdit
            ? Checkbox(
                value: isPresent,
                activeColor: isFree ? freeCheckColor : null,
                onChanged: (_) => onToggle(),
              )
            : AttendanceMark(
                isPresent: isPresent,
                isFree: isFree,
                status: attendance?.status,
              ),
      ),
    );
  }
}
