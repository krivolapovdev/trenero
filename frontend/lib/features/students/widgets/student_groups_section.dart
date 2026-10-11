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

/// The groups of a student, on the student page.
///
/// The mirror image of the students section of a group: the card lists one
/// entry per group the student belongs to, and the button that carries the page
/// picking those groups sits at the bottom of the card. When no action is given
/// the card only lists the groups, and a student without a group keeps no card
/// at all.
class StudentGroupsSection extends ConsumerWidget {
  /// The student the section belongs to, holding the groups they belong to.
  final StudentSummaryResponse student;

  /// Opens the page that updates the groups of the student.
  final VoidCallback? onEdit;

  const new({super.key, required this.student, this.onEdit});

  /// The groups of [student].
  ///
  /// The summary carries the full list of groups the student belongs to; the
  /// single group is the fallback for a response that only holds the primary
  /// one.
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

    // The list of the trainer holds every group with the number of its
    // students, the groups of the student alone carry no count.
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

  /// The group of the student as the group page needs it.
  ///
  /// The list of the trainer wins when it holds the group, so the card carries
  /// the count of the students of the group; a group the list does not hold yet
  /// is widened from the response of the student.
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
