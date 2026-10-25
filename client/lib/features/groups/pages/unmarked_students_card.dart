import 'package:flutter/material.dart';
import 'package:phone/features/groups/pages/student_attendance_tile.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class UnmarkedStudentsCard extends StatelessWidget {
  static const double _cornerRadius = 16;

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
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cornerRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.t.lessons.notMarked,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ),
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
    ),
  );
}
