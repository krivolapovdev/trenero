import 'package:flutter/material.dart';
import 'package:phone/features/rosters/widgets/roster_student_tile.dart';
import 'package:phone/generated/models/student_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';

class RosterStudentListView extends StatelessWidget {
  final List<StudentResponse> students;
  final List<StudentSummaryResponse> fullSummaries;
  final ValueChanged<StudentResponse>? onEditStudent;
  final ValueChanged<String>? onDeleteStudent;
  final ValueChanged<String>? onRemoveStudent;
  final bool isLoading;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;

  const new({
    super.key,
    required this.students,
    this.fullSummaries = const [],
    this.onEditStudent,
    this.onDeleteStudent,
    this.onRemoveStudent,
    this.isLoading = false,
    this.physics = const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    ),
    this.padding = const EdgeInsets.all(16.0),
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: padding,
    physics: physics,
    shrinkWrap: shrinkWrap,
    itemCount: students.length,
    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
    itemBuilder: (context, index) {
      final student = students[index];
      final summary = fullSummaries
          .where((s) => s.id == student.id)
          .firstOrNull;
      final deleteCallback = onDeleteStudent ?? onRemoveStudent;

      return RosterStudentTile(
        key: ValueKey('${student.id}_$index'),
        student: student,
        fullSummary: summary,
        borderRadius: BorderRadius.circular(16),
        enabled: !isLoading,
        onEdit: onEditStudent != null ? () => onEditStudent!(student) : null,
        onDelete: deleteCallback != null
            ? () => deleteCallback(student.id)
            : null,
      );
    },
  );
}
