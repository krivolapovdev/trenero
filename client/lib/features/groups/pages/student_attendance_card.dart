import 'package:flutter/material.dart';
import 'package:phone/features/groups/models/lesson_attendance.dart';
import 'package:phone/features/groups/pages/student_attendance_tile.dart';
import 'package:phone/features/groups/pages/unmarked_students_card.dart';
import 'package:phone/generated/models/group_student_summary_response.dart';
import 'package:phone/generated/models/visit_status.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentAttendanceCard extends StatelessWidget {
  static const double _cornerRadius = 16;

  final List<GroupStudentSummaryResponse> students;
  final Map<String, LessonAttendance> attendance;
  final bool canEdit;
  final bool isAttendanceLoading;
  final bool isLoading;
  final ValueChanged<GroupStudentSummaryResponse> onToggle;
  final ValueChanged<GroupStudentSummaryResponse> onLongPress;
  final VoidCallback onToggleAll;

  const new({
    super.key,
    required this.students,
    required this.attendance,
    required this.canEdit,
    required this.isAttendanceLoading,
    required this.isLoading,
    required this.onToggle,
    required this.onLongPress,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    final markedStudents = students
        .where((student) => attendance.containsKey(student.id))
        .toList();
    final unmarkedStudents = students
        .where((student) => !attendance.containsKey(student.id))
        .toList();
    final isStudentsLoading =
        (isLoading || isAttendanceLoading) && students.isEmpty;
    final allPresent =
        markedStudents.isNotEmpty &&
        markedStudents.every(
          (student) => attendance[student.id]?.status == VisitStatus.present,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Material(
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
                if (isStudentsLoading) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.t.students.title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ] else if (students.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.t.students.title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      context.t.lessons.noStudents,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.t.students.title,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          if (canEdit && markedStudents.isNotEmpty)
                            TextButton(
                              onPressed: onToggleAll,
                              child: Text(
                                allPresent
                                    ? context.t.lessons.deselectAll
                                    : context.t.lessons.selectAll,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  for (final (index, student) in markedStudents.indexed)
                    StudentAttendanceTile(
                      key: ValueKey(student.id),
                      student: student,
                      number: index + 1,
                      attendance: attendance[student.id],
                      canEdit: canEdit,
                      onToggle: () => onToggle(student),
                      onLongPress: () => onLongPress(student),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (unmarkedStudents.isNotEmpty)
          UnmarkedStudentsCard(
            students: unmarkedStudents,
            firstNumber: markedStudents.length + 1,
            canEdit: canEdit,
            onToggle: onToggle,
            onLongPress: onLongPress,
          ),
      ],
    );
  }
}
