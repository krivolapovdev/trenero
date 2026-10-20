import 'package:flutter/material.dart';
import 'package:phone/features/groups/pages/group_page.dart';
import 'package:phone/features/groups/widgets/group_card.dart';
import 'package:phone/generated/models/group_response.dart';
import 'package:phone/generated/models/group_summary_response.dart';
import 'package:phone/i18n/strings.g.dart';

class StudentGroupsCard extends StatelessWidget {
  final List<GroupResponse> groups;
  final List<GroupSummaryResponse> listedGroups;
  final VoidCallback? onEdit;

  const new({
    super.key,
    required this.groups,
    required this.listedGroups,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    padding: const EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
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
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: groups.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final group = _summaryOf(groups[index], listedGroups);

            return GroupCard(
              key: ValueKey(group.id),
              group: group,
              noteVisible: false,
              borderRadius: BorderRadius.zero,
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
