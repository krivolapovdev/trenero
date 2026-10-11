import 'package:flutter/material.dart';
import 'package:phone/core/widgets/retry_view.dart';
import 'package:phone/features/groups/widgets/group_students_empty.dart';
import 'package:phone/features/groups/widgets/group_students_placeholder.dart';
import 'package:phone/features/groups/widgets/student_checkbox_tile.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class GroupStudentsBody extends StatelessWidget {
  final List<StudentSummaryResponse> students;
  final Set<String> pickedStudentIds;
  final bool isLoading;
  final bool hasError;
  final Object? error;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const new({
    super.key,
    required this.students,
    required this.pickedStudentIds,
    required this.isLoading,
    required this.hasError,
    required this.onToggle,
    required this.onRetry,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError && students.isEmpty) {
      return RetryView(message: '$error', onRetry: onRetry);
    }

    if (!isLoading && students.isEmpty) {
      return const GroupStudentsEmpty();
    }

    final displayStudents = students.isEmpty
        ? groupStudentsPlaceholderStudents
        : students;

    return Skeletonizer(
      enabled: isLoading,
      ignorePointers: false,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: displayStudents.length,
              itemBuilder: (context, index) {
                final student = displayStudents[index];

                return StudentCheckboxTile(
                  key: ValueKey(student.id),
                  student: student,
                  selected: pickedStudentIds.contains(student.id),
                  enabled: !isLoading,
                  onToggle: () => onToggle(student.id),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
