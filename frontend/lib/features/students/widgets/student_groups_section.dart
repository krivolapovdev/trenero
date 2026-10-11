import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/students/widgets/student_groups_card.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentGroupsSection extends ConsumerWidget {
  final StudentSummaryResponse student;

  final VoidCallback? onEdit;

  const new({super.key, required this.student, this.onEdit});

  static List<GroupResponse> _groupsOf(StudentSummaryResponse student) {
    final groups = student.studentGroups;

    if (groups != null && groups.isNotEmpty) {
      return groups;
    }

    final group = student.studentGroup;
    return group == null ? const <GroupResponse>[] : [group];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = _groupsOf(student);

    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupsState = ref.watch(groupListControllerProvider);
    final listedGroups = groupsState.value ?? const <GroupSummaryResponse>[];

    return Skeletonizer(
      enabled: groupsState.isLoading,
      ignorePointers: false,
      child: StudentGroupsCard(
        groups: groups,
        listedGroups: listedGroups,
        onEdit: onEdit,
      ),
    );
  }
}
