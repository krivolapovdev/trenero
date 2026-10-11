import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone/features/groups/controllers/group_list_controller.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/generated/models/student_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';
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
      child: _buildSection(context, groups, listedGroups),
    );
  }

  Widget _buildSection(
    BuildContext context,
    List<GroupResponse> groups,
    List<GroupSummaryResponse> listedGroups,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.t.groups.title,
              style: const TextStyle(fontSize: 18, color: Colors.black),
            ),
            if (onEdit != null)
              TextButton(
                onPressed: onEdit,
                child: Text(
                  context.t.edit,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: groups.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 16, thickness: 1),
          itemBuilder: (context, index) {
            final group = _summaryOf(groups[index], listedGroups);

            return GroupCard(
              group: group,
              noteVisible: false,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GroupPage(group: group),
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );

  static GroupSummaryResponse _summaryOf(
    GroupResponse group,
    List<GroupSummaryResponse> listedGroups,
  ) {
    for (final listed in listedGroups) {
      if (listed.id == group.id) return listed;
    }

    return GroupSummaryResponse(
      id: group.id,
      name: group.name,
      createdAt: group.createdAt,
      defaultPrice: group.defaultPrice,
      note: group.note,
    );
  }
}
