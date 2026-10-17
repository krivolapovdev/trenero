import 'package:flutter/material.dart';
import 'package:phone/features/groups/pages/student_attendance_tile.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class UnmarkedStudentsAccordion extends StatelessWidget {
  final List<GroupStudentSummaryResponse> students;
  final int firstNumber;
  final bool canEdit;
  final ValueChanged<GroupStudentSummaryResponse> onToggle;
  final ValueChanged<GroupStudentSummaryResponse> onLongPress;

  const new({
    super.key,
    required this.students,
    required this.firstNumber,
    required this.canEdit,
    required this.onToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text(
        context.t.lessons.notMarked,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      children: [
        for (final (index, student) in students.indexed)
          StudentAttendanceTile(
            key: ValueKey(student.id),
            student: student,
            number: firstNumber + index,
            canEdit: canEdit,
            unmarked: true,
            onToggle: () => onToggle(student),
            onLongPress: () => onLongPress(student),
          ),
      ],
    ),
  );
}
