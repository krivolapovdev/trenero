import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:phone/features/finance/widgets/locked_student_field.dart';
import 'package:phone/features/finance/widgets/student_selector_field.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentField extends StatelessWidget {
  final bool isLocked;
  final String? lockedStudentName;
  final List<StudentSummaryResponse> students;
  final bool isLoading;
  final String? selectedStudentId;
  final bool isExpanded;
  final bool isSubmitting;
  final VoidCallback onToggle;
  final ValueChanged<String?> onSelect;

  const new({
    super.key,
    required this.isLocked,
    required this.students,
    required this.isLoading,
    required this.selectedStudentId,
    required this.isExpanded,
    required this.isSubmitting,
    required this.onToggle,
    required this.onSelect,
    this.lockedStudentName,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      final selectedName = students
          .where((student) => student.id == selectedStudentId)
          .firstOrNull
          ?.fullName;

      return LockedStudentField(name: selectedName ?? lockedStudentName);
    }

    if (students.isEmpty) {
      if (!isLoading) return const SizedBox.shrink();

      return Skeletonizer(
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: context.t.finance.student,
            prefixIcon: const Icon(FluentIcons.person_16_regular),
          ),
        ),
      );
    }

    return StudentSelectorField(
      students: students,
      selectedStudentId: selectedStudentId,
      isExpanded: isExpanded,
      isSubmitting: isSubmitting,
      onToggle: onToggle,
      onSelect: onSelect,
    );
  }
}
